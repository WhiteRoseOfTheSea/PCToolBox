using System.Threading.Tasks;
using AtlasToolbox.Utils;
using MVVMEssentials.Commands;

namespace AtlasToolbox.Commands.ConfigurationButtonsCommand
{
    public class OpenNetplwizCommand : AsyncCommandBase
    {
        protected override async Task ExecuteAsync(object parameter)
        {
            await Task.Run(() => { ProcessHelper.StartShellExecute("netplwiz"); });
        }
    }
}
