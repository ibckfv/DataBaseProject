namespace DbHomework;

public class TaskItem
{
    public long Id { get; set; }
    public string TaskType { get; set; } = string.Empty;
    public string Payload { get; set; } = string.Empty;
    public int Attempts { get; set; }
}