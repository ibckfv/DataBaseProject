using DbHomework;

if (args.Length == 0)
{
    Console.WriteLine("Usage: PgQueueDemo producer|worker [workerId]");
    return;
}

var mode = args[0].ToLower();

if (mode == "producer")
{
    var producer = new ProducerService();
    var cts = new CancellationTokenSource();
    Console.CancelKeyPress += (s, e) => { e.Cancel = true; cts.Cancel(); };
    await producer.RunAsync(ratePerSec: 50, cts.Token);
}
else if (mode == "worker")
{
    var workerId = args.Length > 1 ? args[1] : "worker_1";
    var worker = new WorkerService(workerId);
    var cts = new CancellationTokenSource();
    Console.CancelKeyPress += (s, e) => { e.Cancel = true; cts.Cancel(); };
    await worker.RunAsync(cts.Token);
}
else
{
    Console.WriteLine("Unknown mode. Use 'producer' or 'worker'.");
}