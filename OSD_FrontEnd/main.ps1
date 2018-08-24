<# 
.SYNOPSIS
    Runs 
.NOTES
    AUTHOR - Joseph Fenly
#>

Import-Module ./OSD_HW
Import-Module ./OSD_Network

# Variables


$ixaml = @"
<Window x:Class="QuickOSD.UserInterface"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:QuickOSD"
        mc:Ignorable="d"
                Title="QuickOSD" Height="550" Width="750" Background="#FFF9F9F9" 
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize" WindowStyle="None">
    <Grid>
        <Border BorderBrush="#FFF9F9F9" BorderThickness="2" Margin="357,51,26,0" Background="#FF383636" Height="443" VerticalAlignment="Top" CornerRadius="9">
            <StackPanel Margin="8" >
                <Label x:Name="statusIndicatorTitle" Height="27" Content="Status Indicator" Foreground="#FFF9F9F9" BorderThickness="0,0,0,2" BorderBrush="#FFF9F9F9"/>
                <RichTextBox x:Name="statusTextBox" Margin="0,5,0,0" Height="340" Width="331" Background="#FF383636" Foreground="#FFF9F9F9" IsReadOnly="True">
                    <FlowDocument>
                        <Paragraph>
                            <Run Text=""/>
                        </Paragraph>
                    </FlowDocument>
                </RichTextBox>
                <Border BorderBrush="#FFF9F9F9" BorderThickness="2" Background="#FF383636" CornerRadius="9" Height="26" VerticalAlignment="Top" Margin="120,15,120,0" Width="90">
                    <Button x:Name="retryButton" Content="Retry" Margin="0,0,8,0" BorderThickness="0" Background="#FF383636" Foreground="#FFF9F7F7" HorizontalAlignment="Right" Width="72"/>
                </Border>
            </StackPanel>
        </Border>
        <StackPanel HorizontalAlignment="Left" Height="322" Margin="29,51,0,0" VerticalAlignment="Top" Width="247">
            <Label x:Name="deviceInfo" Content="Device Information" BorderThickness="0,0,0,2" BorderBrush="#FF383636" Margin="0,0,10,0"/>
            <Label x:Name="userName" Content="Built By" Margin="0,18,0,0"/>
            <StackPanel Orientation="Horizontal">
                <Border BorderBrush="#FFF9F9F9" BorderThickness="2" Background="#FF383636" CornerRadius="9" HorizontalAlignment="Right" Width="235" Margin="7,0,0,0" Height="31">
                    <TextBox x:Name="userNameInput" TextWrapping="Wrap" Text="" ToolTip="Please enter your first and last names." Background="#FF383636" Width="215" Margin="0,3,8,0" Foreground="#FFF9F9F9" BorderThickness="0"  HorizontalAlignment="Right" Height="20" VerticalAlignment="Top"/>
                </Border>
            </StackPanel>
            <Label x:Name="computerName" Content="Computer Name" Margin="0,10,0,0"/>
            <StackPanel Orientation="Horizontal">
                <Border BorderBrush="#FFF9F9F9" BorderThickness="2" Background="#FF383636" CornerRadius="9" HorizontalAlignment="Right" Width="235" Margin="7,0,0,0" Height="30">
                    <TextBox x:Name="computerNameInput" Height="20" TextWrapping="Wrap" Text="" ToolTip="Laptops: dur-lp-xxx, Desktops: dur-ws-xxx, Surfaces: dur-surface-xxx" Background="#FF383636" HorizontalAlignment="Right" Width="215" Margin="0,3,8,3" Foreground="#FFF9F9F9" BorderThickness="0"/>
                </Border>
            </StackPanel>
            <Border BorderBrush="#FFF9F9F9" BorderThickness="2" Background="#FF383636" CornerRadius="9" Margin="45,40,45,0" Height="26">
                <Button x:Name="tsContinueButton" Content="Continue" Background="#FF383636" Foreground="#FFF9F7F7" Margin="8,0,8,0" BorderThickness="0" IsEnabled="False"/>
            </Border>
        </StackPanel>
        <Border BorderBrush="#FFF9F9F9" BorderThickness="2" Background="#FF383636" CornerRadius="9" Margin="32,371,0,0" Height="26" HorizontalAlignment="Left" Width="94" VerticalAlignment="Top">
            <Button x:Name="cmtraceButton" Content="CmTrace" Margin="8,0,8,0" BorderThickness="0" Background="#FF383636" Foreground="#FFF9F7F7" HorizontalAlignment="Right" Width="75" Height="20" VerticalAlignment="Bottom" />
        </Border>
        <Border BorderBrush="#FFF9F9F9" BorderThickness="2" Background="#FF383636" CornerRadius="9" Margin="185,371,0,0" HorizontalAlignment="Left" Width="94" Height="26" VerticalAlignment="Top">
            <Button x:Name="f8Button" Content="CMD" Margin="8,0,8,0" BorderThickness="0" Background="#FF383636" Foreground="#FFF9F7F7" HorizontalAlignment="Right" Width="75" />
        </Border>
    </Grid>
</Window>
"@

# Clean UI code programatically and create the XAML object and export variables
$ixaml = $ixaml -replace 'mc:Ignorable="d"','' -replace "x:N",'N' `
    -replace '^<Win.*', '<Window'
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
[xml]$xaml = $ixaml
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $form = [Windows.Markup.XamlReader]::Load($reader)
    return $form
} catch {
    return $Error[0]
    exit
}
$xaml.SelectNodes("//*[@Name]") | % {
    Set-Variable -Name "WPF$($_.Name)" -Value $form.FindName($_.Name)
}

function Set-VerboseInfo ($message) {
    <#
    .SYNOPSIS
        Append information to the verbose log
    #>
    return $WPFstatusTextBox.Appendtext($message + [char]13)
}
function Start-StatusChecks {
    <#
    .SYNOPSIS
        Core functionality - Runs all the status check tools
    #>
    Set-VerboseInfo -message "INFO: Starting network checks"
    if ((Get-EthStatus).ToString() -eq "2") {
        Set-VerboseInfo -message "INFO: Getting IP address assigned to Ethernet adapter"
        if (Get-EthIP -eq "fail") {
            $LANCHECK = "fail"
        } else {
            Set-VerboseInfo -message "INFO: IP Address is: $((Get-EthIP).ToString())"
            $LANCHECK = "pass"
        }
    } else {
        Set-VerboseInfo -message "ERROR: No Ethernet cable connected"
    }
    
}

# Run UI
[void]$form.ShowDialog()