using Npgsql;

namespace DbHomework;

public class TaskQueueRepository
{
    private readonly NpgsqlConnection _conn;

    public TaskQueueRepository(NpgsqlConnection conn) => _conn = conn;

    public async Task InsertTaskAsync(
        NpgsqlTransaction tx,
        string taskType,
        string payloadJson,
        int priority)
    {
        await using var cmd = new NpgsqlCommand(
            @"INSERT INTO tasks (task_type, payload, priority, scheduled_at)
              VALUES ($1, $2::jsonb, $3, now())", _conn, tx);
        cmd.Parameters.AddWithValue(taskType);
        cmd.Parameters.AddWithValue(payloadJson);
        cmd.Parameters.AddWithValue(priority);
        await cmd.ExecuteNonQueryAsync();
    }

    public async Task NotifyAsync(NpgsqlTransaction tx)
    {
        await using var cmd = new NpgsqlCommand("NOTIFY new_task", _conn, tx);
        await cmd.ExecuteNonQueryAsync();
    }

    /// <summary>
    /// Пытается атомарно забрать одну задачу из очереди.
    /// Возвращает задачу или null, если готовых задач нет.
    /// </summary>
    public async Task<TaskItem?> TryDequeueAsync(NpgsqlTransaction tx)
    {
        await using var cmd = new NpgsqlCommand(
            @"SELECT id, task_type, payload, attempts
              FROM tasks
              WHERE status = 'ready' AND scheduled_at <= now()
              ORDER BY priority DESC, scheduled_at
              LIMIT 1
              FOR UPDATE SKIP LOCKED", _conn, tx);

        await using var reader = await cmd.ExecuteReaderAsync();
        if (!await reader.ReadAsync())
            return null;

        var task = new TaskItem
        {
            Id = reader.GetInt64(0),
            TaskType = reader.GetString(1),
            Payload = reader.GetString(2),
            Attempts = reader.GetInt32(3)
        };
        await reader.CloseAsync();

        // Переводим в running
        await using var updateCmd = new NpgsqlCommand(
            "UPDATE tasks SET status='running', worker_id=$1, started_at=now() WHERE id=$2",
            _conn, tx);
        updateCmd.Parameters.AddWithValue(GetWorkerId());
        updateCmd.Parameters.AddWithValue(task.Id);
        await updateCmd.ExecuteNonQueryAsync();

        return task;
    }

    public async Task CompleteAsync(long taskId)
    {
        await using var cmd = new NpgsqlCommand(
            "UPDATE tasks SET status='completed', finished_at=now() WHERE id=$1", _conn);
        cmd.Parameters.AddWithValue(taskId);
        await cmd.ExecuteNonQueryAsync();
    }

    public async Task FailAsync(long taskId, int newAttempts, string error)
    {
        if (newAttempts < 3)
        {
            int delaySec = 5 * (int)Math.Pow(2, newAttempts);
            DateTime newScheduled = DateTime.UtcNow.AddSeconds(delaySec);
            await using var cmd = new NpgsqlCommand(
                @"UPDATE tasks SET status='ready', attempts=$1, scheduled_at=$2,
                  error_message=$3, worker_id=NULL WHERE id=$4", _conn);
            cmd.Parameters.AddWithValue(newAttempts);
            cmd.Parameters.AddWithValue(newScheduled);
            cmd.Parameters.AddWithValue(error);
            cmd.Parameters.AddWithValue(taskId);
            await cmd.ExecuteNonQueryAsync();
        }
        else
        {
            await using var cmd = new NpgsqlCommand(
                @"UPDATE tasks SET status='failed', attempts=$1,
                  error_message=$2, finished_at=now() WHERE id=$3", _conn);
            cmd.Parameters.AddWithValue(newAttempts);
            cmd.Parameters.AddWithValue(error);
            cmd.Parameters.AddWithValue(taskId);
            await cmd.ExecuteNonQueryAsync();
        }
    }

    // Заглушка для worker_id (можно брать из env или аргументов)
    private static string GetWorkerId() => 
        Environment.GetEnvironmentVariable("WORKER_ID") ?? "unknown_worker";
}