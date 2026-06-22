using System.Configuration;

namespace AtlasToolbox.Utils
{
    public class CompatibilityHelper
    {
        /// <summary>
        /// Check compatibility with app's version
        /// </summary>
        /// <returns></returns>
        public static bool IsCompatible()
        {
            string[] compatibleVersions = ConfigurationManager.AppSettings.Get("PCToolsVersion").Split(',');
            string appliedVersion = (string)RegistryHelper.GetValue("HKLM\\SOFTWARE\\AME\\Playbooks\\Applied\\{40f095dc-77be-4e64-91f9-9626b4ffc421}", "version");
            foreach (string version in compatibleVersions)
            {
                if (appliedVersion == version) return true;
            }
            return false;
        }
    }
}
