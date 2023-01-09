using System.Collections.Concurrent;
using System.Threading.Tasks.Dataflow;

namespace Application.Extensions;

public static class EnumerableExtensions
{
    public static Task ParallelForEachAsync<T>(this IEnumerable<T> source, Func<T, Task> body, int maxDegreeOfParallelism = DataflowBlockOptions.Unbounded, TaskScheduler scheduler = null)
    {
        var options = new ExecutionDataflowBlockOptions
        {
            MaxDegreeOfParallelism = maxDegreeOfParallelism
        };
        if (scheduler != null)
            options.TaskScheduler = scheduler;

        var block = new ActionBlock<T>(body, options);

        foreach (var item in source)
            block.Post(item);

        block.Complete();
        return block.Completion;
    }
}