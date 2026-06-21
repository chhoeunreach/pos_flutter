using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Runtime.InteropServices;

internal static class PosAppSetup
{
    private static readonly byte[] Marker =
        System.Text.Encoding.ASCII.GetBytes("POS_APP_SETUP_PAYLOAD_V1");

    [STAThread]
    private static int Main()
    {
        try
        {
            string appName = "POS App";
            string installRoot = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "Programs",
                appName);
            string exePath = Path.Combine(installRoot, "pos_app.exe");
            string tempZip = Path.Combine(Path.GetTempPath(), "pos_app_windows_release.zip");

            ExtractPayload(tempZip);

            if (Directory.Exists(installRoot))
            {
                Directory.Delete(installRoot, true);
            }
            Directory.CreateDirectory(installRoot);
            ZipFile.ExtractToDirectory(tempZip, installRoot);

            CreateShortcut(
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory), appName + ".lnk"),
                exePath,
                installRoot);

            string startMenuDir = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.Programs),
                appName);
            Directory.CreateDirectory(startMenuDir);
            CreateShortcut(Path.Combine(startMenuDir, appName + ".lnk"), exePath, installRoot);

            Process.Start(new ProcessStartInfo
            {
                FileName = exePath,
                WorkingDirectory = installRoot,
                UseShellExecute = true
            });
            return 0;
        }
        catch (Exception ex)
        {
            System.Windows.Forms.MessageBox.Show(
                ex.Message,
                "POS App Setup",
                System.Windows.Forms.MessageBoxButtons.OK,
                System.Windows.Forms.MessageBoxIcon.Error);
            return 1;
        }
    }

    private static void ExtractPayload(string outputZip)
    {
        string self = Assembly.GetExecutingAssembly().Location;
        byte[] allBytes = File.ReadAllBytes(self);
        if (allBytes.Length < 8 + Marker.Length)
        {
            throw new InvalidOperationException("Installer payload is missing.");
        }

        long payloadLength = BitConverter.ToInt64(allBytes, allBytes.Length - 8);
        long markerOffset = allBytes.Length - 8 - payloadLength - Marker.Length;
        long payloadOffset = markerOffset + Marker.Length;
        if (payloadLength <= 0 || markerOffset < 0)
        {
            throw new InvalidOperationException("Installer payload is invalid.");
        }

        for (int i = 0; i < Marker.Length; i++)
        {
            if (allBytes[markerOffset + i] != Marker[i])
            {
                throw new InvalidOperationException("Installer payload marker was not found.");
            }
        }

        using (FileStream output = File.Create(outputZip))
        {
            output.Write(allBytes, (int)payloadOffset, (int)payloadLength);
        }
    }

    private static void CreateShortcut(string shortcutPath, string targetPath, string workingDirectory)
    {
        Type shellType = Type.GetTypeFromProgID("WScript.Shell");
        if (shellType == null) return;

        object shell = Activator.CreateInstance(shellType);
        object shortcut = shellType.InvokeMember(
            "CreateShortcut",
            BindingFlags.InvokeMethod,
            null,
            shell,
            new object[] { shortcutPath });

        Type shortcutType = shortcut.GetType();
        shortcutType.InvokeMember("TargetPath", BindingFlags.SetProperty, null, shortcut, new object[] { targetPath });
        shortcutType.InvokeMember("WorkingDirectory", BindingFlags.SetProperty, null, shortcut, new object[] { workingDirectory });
        shortcutType.InvokeMember("IconLocation", BindingFlags.SetProperty, null, shortcut, new object[] { targetPath + ",0" });
        shortcutType.InvokeMember("Save", BindingFlags.InvokeMethod, null, shortcut, null);

        Marshal.FinalReleaseComObject(shortcut);
        Marshal.FinalReleaseComObject(shell);
    }
}
