using Npgsql;
using System.Text.Json;

namespace DbHomework;

public class WorkerService
{
    private readonly NpgsqlConnection _conn;
    private readonly TaskQueueRepository _repo;
    private readonly string _workerId;
    private readonly Random _rng = new();

    public WorkerService(string workerId)
    {
        _workerId = workerId;
        _conn = new NpgsqlConnection(DatabaseConfig.ConnectionString);
        _repo = new TaskQueueRepository(_conn);
        // Устанавливаем ID воркера в окружение, чтобы репозиторий мог его подхватить
        Environment.SetEnvironmentVariable("WORKER_ID", _workerId);
    }

    public async Task RunAsync(CancellationToken ct)
    {
        await _conn.OpenAsync(ct);
        // Подписка на уведомления
        await using var listenCmd = new NpgsqlCommand("LISTEN new_task", _conn);
        await listenCmd.ExecuteNonQueryAsync(ct);

        Console.WriteLine($"{_workerId} started. Listening for tasks...");

        while (!ct.IsCancellationRequested)
        {
            await using var tx = await _conn.BeginTransactionAsync(ct);
            try
            {
                var task = await _repo.TryDequeueAsync(tx);
                if (task == null)
                {
                    await tx.CommitAsync(ct);
                    // Ждём уведомление с таймаутом
                    await WaitForNotification(ct, TimeSpan.FromSeconds(1));
                    continue;
                }

                await tx.CommitAsync(ct); // статус уже обновлён на running

                bool success = await ProcessTask(task);
                if (success)
                    await _repo.CompleteAsync(task.Id);
                // В случае ошибки ProcessTask сам вызывает FailAsync
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                await tx.RollbackAsync(ct);
                Console.WriteLine($"{_workerId}: error in main loop - {ex.Message}");
                await Task.Delay(500, ct);
            }
        }
        Console.WriteLine($"{_workerId} stopped.");
    }

    private async Task<bool> ProcessTask(TaskItem task)
    {
        var payload = JsonSerializer.Deserialize<JsonElement>(task.Payload);
        int orderId = payload.GetProperty("order_id").GetInt32();

        try
        {
            switch (task.TaskType)
            {
                case "calculate_cost":
                    await CalculateCost(orderId);
                    break;
                case "update_status":
                    await UpdateOrderStatus(orderId);
                    break;
                case "generate_invoice":
                    await GenerateInvoice(orderId);
                    break;
                default:
                    throw new InvalidOperationException($"Unknown task type: {task.TaskType}");
            }
            Console.WriteLine($"{_workerId}: completed {task.TaskType} for order {orderId}");
            return true;
        }
        catch (Exception ex)
        {
            int newAttempts = task.Attempts + 1;
            await _repo.FailAsync(task.Id, newAttempts, ex.Message);
            Console.WriteLine(
                $"{_workerId}: failed {task.TaskType} for order {orderId}, attempt {newAttempts}/3");
            return false;
        }
    }

    private async Task CalculateCost(int orderId)
    {
        await using var cmd = new NpgsqlCommand(
            @"SELECT calculate_cargo_price(
                (SELECT cargo_id FROM cargos WHERE order_id = $1 LIMIT 1)
            )", _conn);
        cmd.Parameters.AddWithValue(orderId);
        var cost = await cmd.ExecuteScalarAsync();
        await Task.Delay(_rng.Next(100, 500));
        Console.WriteLine($"{_workerId}: calculated cost {cost} for order {orderId}");
    }

    private async Task UpdateOrderStatus(int orderId)
    {
        await using var cmd = new NpgsqlCommand(
            "UPDATE orders SET status = 'Доставлен' WHERE order_id = $1", _conn);
        cmd.Parameters.AddWithValue(orderId);
        await cmd.ExecuteNonQueryAsync();
        await Task.Delay(_rng.Next(200, 700));
    }

    private async Task GenerateInvoice(int orderId)
    {
        await using var cmd = new NpgsqlCommand(
            @"INSERT INTO invoices (order_id, amount)
              SELECT $1, COALESCE(total_cost, 0) FROM orders WHERE order_id = $1", _conn);
        cmd.Parameters.AddWithValue(orderId);
        await cmd.ExecuteNonQueryAsync();
        await Task.Delay(_rng.Next(300, 800));
    }

    private async Task WaitForNotification(CancellationToken ct, TimeSpan timeout)
    {
        var tcs = new TaskCompletionSource<bool>();
    
        void OnNotification(object sender, NpgsqlNotificationEventArgs e)
        {
            // Можно записать полезную нагрузку, если нужно
            Console.WriteLine($"{_workerId}: received NOTIFY for task {e.Payload}");
            tcs.TrySetResult(true);
        }

        _conn.Notification += OnNotification;
        try
        {
            using var timeoutCts = new CancellationTokenSource(timeout);
            using var linkedCts = CancellationTokenSource.CreateLinkedTokenSource(ct, timeoutCts.Token);
            // Ждём либо уведомление, либо таймаут, либо внешний CancellationToken
            await Task.WhenAny(tcs.Task, Task.Delay(Timeout.Infinite, linkedCts.Token));
        }
        finally
        {
            _conn.Notification -= OnNotification;
        }
    }
}