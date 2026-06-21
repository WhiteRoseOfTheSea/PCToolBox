using System;
using System.Threading.Tasks;
using AtlasToolbox.Utils;
using MVVMEssentials.Commands;

namespace AtlasToolbox.Commands.ConfigurationButtonsCommand
{
    public class UninstallDriverToolCommand : AsyncCommandBase
    {
        protected override async Task ExecuteAsync(object parameter)
        {
            await Task.Run(() => { ProcessHelper.StartShellExecute(@$"{Environment.GetEnvironmentVariable("windir")}\PCToolsModules\Toolbox\Scripts\Drivers\UninstallDriverTool.cmd"); });
        }
    }
}
