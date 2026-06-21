using AtlasToolbox.Stores;
using AtlasToolbox.Utils;
using Microsoft.Extensions.DependencyInjection;
using System.Linq;

namespace AtlasToolbox.Services.ConfigurationServices
{
    public class DesktopIconsConfigurationService : IConfigurationService
    {
        private const string HIDE_DESKTOP_ICONS_KEY_NAME = @"HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel";

        private const string THIS_PC_VALUE_NAME = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}";
        private const string USERS_FILES_VALUE_NAME = "{59031a47-3f72-44a7-89c5-5595fe6b30ee}";
        private const string NETWORK_VALUE_NAME = "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}";
        private const string RECYCLE_BIN_VALUE_NAME = "{645FF040-5081-101B-9F08-00AA002F954E}";
        private const string CONTROL_PANEL_VALUE_NAME = "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}";

        private readonly ConfigurationStore _desktopIconsConfigurationStore;

        public DesktopIconsConfigurationService(
            [FromKeyedServices("DesktopIcons")] ConfigurationStore desktopIconsConfigurationStore)
        {
            _desktopIconsConfigurationStore = desktopIconsConfigurationStore;
        }

        public void Disable()
        {
            RegistryHelper.SetValue(HIDE_DESKTOP_ICONS_KEY_NAME, THIS_PC_VALUE_NAME, 1);
            RegistryHelper.SetValue(HIDE_DESKTOP_ICONS_KEY_NAME, USERS_FILES_VALUE_NAME, 1);
            RegistryHelper.SetValue(HIDE_DESKTOP_ICONS_KEY_NAME, NETWORK_VALUE_NAME, 1);
            RegistryHelper.SetValue(HIDE_DESKTOP_ICONS_KEY_NAME, RECYCLE_BIN_VALUE_NAME, 1);
            RegistryHelper.SetValue(HIDE_DESKTOP_ICONS_KEY_NAME, CONTROL_PANEL_VALUE_NAME, 1);

            _desktopIconsConfigurationStore.CurrentSetting = IsEnabled();
        }

        public void Enable()
        {
            RegistryHelper.SetValue(HIDE_DESKTOP_ICONS_KEY_NAME, THIS_PC_VALUE_NAME, 0);
            RegistryHelper.SetValue(HIDE_DESKTOP_ICONS_KEY_NAME, USERS_FILES_VALUE_NAME, 0);
            RegistryHelper.SetValue(HIDE_DESKTOP_ICONS_KEY_NAME, NETWORK_VALUE_NAME, 0);
            RegistryHelper.SetValue(HIDE_DESKTOP_ICONS_KEY_NAME, RECYCLE_BIN_VALUE_NAME, 0);
            RegistryHelper.SetValue(HIDE_DESKTOP_ICONS_KEY_NAME, CONTROL_PANEL_VALUE_NAME, 0);

            _desktopIconsConfigurationStore.CurrentSetting = IsEnabled();
        }

        public bool IsEnabled()
        {
            bool[] checks =
            {
                RegistryHelper.IsMatch(HIDE_DESKTOP_ICONS_KEY_NAME, THIS_PC_VALUE_NAME, 0),
                RegistryHelper.IsMatch(HIDE_DESKTOP_ICONS_KEY_NAME, USERS_FILES_VALUE_NAME, 0),
                RegistryHelper.IsMatch(HIDE_DESKTOP_ICONS_KEY_NAME, NETWORK_VALUE_NAME, 0),
                RegistryHelper.IsMatch(HIDE_DESKTOP_ICONS_KEY_NAME, RECYCLE_BIN_VALUE_NAME, 0),
                RegistryHelper.IsMatch(HIDE_DESKTOP_ICONS_KEY_NAME, CONTROL_PANEL_VALUE_NAME, 0)
            };

            return checks.All(x => x);
        }
    }
}
