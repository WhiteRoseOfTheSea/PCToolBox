using System;
using System.Text.Json;
using System.IO;

namespace AtlasToolbox.Utils
{
    public class ToolboxUpdateHelper
    {
        // Publish updates as a GitHub Release tagged e.g. "v1.0.0", with a
        // "PCToolsToolbox-Setup.exe" asset attached to the release.
        const string GITHUB_REPO = "WhiteRoseOfTheSea/PCToolBox";

        const string LATEST_RELEASE_API_URL = $"https://api.github.com/repos/{GITHUB_REPO}/releases/latest";
        const string ASSET_NAME = "PCToolsToolbox-Setup.exe";

        public static string commandUpdate;
        public static string version = "";
        private static string _downloadUrl = "";

        public static bool CheckUpdates()
        {
            try
            {
                string jsonContent = CommandPromptHelper.ReturnRunCommand($"curl -H \"User-Agent: PCTools-Toolbox\" {LATEST_RELEASE_API_URL}");
                using JsonDocument result = JsonDocument.Parse(jsonContent);

                version = result.RootElement.GetProperty("tag_name").ToString().TrimStart('v');

                foreach (JsonElement asset in result.RootElement.GetProperty("assets").EnumerateArray())
                {
                    if (asset.GetProperty("name").ToString() == ASSET_NAME)
                    {
                        _downloadUrl = asset.GetProperty("browser_download_url").ToString();
                        break;
                    }
                }

                if (string.IsNullOrEmpty(_downloadUrl))
                {
                    return false;
                }

                int currentVersion = int.Parse(RegistryHelper.GetValue($@"HKLM\SOFTWARE\PCTools\Toolbox", "Version").ToString().Replace(".", ""));

                if (int.Parse(version.Replace(".", "")) > currentVersion)
                {
                    return true;
                }
            }
            catch (Exception e)
            {
                App.logger.Error(e, "Failed to check for updates");
                return false;
            }
            return false;
        }

        public static void InstallUpdate()
        {
            string tempDirectory = Path.Combine(Path.GetTempPath(), Path.GetRandomFileName());
            Directory.CreateDirectory(tempDirectory);

            CommandPromptHelper.RunCommand($"cd {tempDirectory} && curl -LSs {_downloadUrl} -o \"{ASSET_NAME}\"");
            commandUpdate = $"{tempDirectory}\\{ASSET_NAME} /silent /install";
            CommandPromptHelper.RunCommandToUpdate(commandUpdate);
        }
    }
}
