using Npgsql;
using System.Text.Json;

namespace DbHomework;

public class ProducerService
{
    private readonly NpgsqlConnection _conn;
    private readonly TaskQueueRepository _repo;
    private static readonly string[] TaskTypes = { "calculate_cost", "update_status", "generate_invoice" };
    private readonly Random _rng = new();

    public ProducerService()
    {
        _conn = new NpgsqlConnection(DatabaseConfig.ConnectionString);
        _repo = new TaskQueueRepository(_conn);
    }

    public async Task RunAsync(int ratePerSec, CancellationToken ct)
    {
        await _conn.OpenAsync(ct);
        Console.WriteLine("Producer started. Press Ctrl+C to stop.");
        var delay = TimeSpan.FromSeconds(1.0 / ratePerSec);

        try
        {
            while (!ct.IsCancellationRequested)
            {
                await using var tx = await _conn.BeginTransactionAsync(ct);
                try
                {
                    // Получить случайный заказ
                    await using var orderCmd = new NpgsqlCommand(
                        "SELECT order_id FROM orders ORDER BY random() LIMIT 1", _conn, tx);
                    var orderId = (int?)await orderCmd.ExecuteScalarAsync(ct);
                    if (orderId == null)
                    {
                        await tx.RollbackAsync(ct);
                        continue;
                    }

                    // Фиктивная бизнес-логика
                    await using var logCmd = new NpgsqlCommand(
                        "INSERT INTO order_logs (order_id, action, user_name) VALUES ($1, $2, $3)",
                        _conn, tx);
                    logCmd.Parameters.AddWithValue(orderId.Value);
                    logCmd.Parameters.AddWithValue("producer_task_created");
                    logCmd.Parameters.AddWithValue("producer");
                    await logCmd.ExecuteNonQueryAsync(ct);

                    // Создание задачи
                    string taskType = TaskTypes[_rng.Next(TaskTypes.Length)];
                    var payload = JsonSerializer.Serialize(new { order_id = orderId.Value });
                    int priority = _rng.NextDouble() < 0.2 ? 100 : 0;

                    await _repo.InsertTaskAsync(tx, taskType, payload, priority);
                    await _repo.NotifyAsync(tx);

                    await tx.CommitAsync(ct);
                    Console.WriteLine($"Produced: {taskType} for order {orderId}, priority={priority}");
                }
                catch
                {
                    await tx.RollbackAsync(ct);
                    throw;
                }

                await Task.Delay(delay, ct);
            }
        }
        catch (OperationCanceledException) { }
        finally
        {
            await _conn.CloseAsync();
        }
        Console.WriteLine("Producer stopped.");
    }
}