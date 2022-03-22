set-location $PSScriptRoot

<#
$ErrorActionPreference = "Inquire"
#>

if (!(Get-Module Poshstache))
{
  $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

  $installScript = "Install-Module -Name Poshstache -Scope AllUsers -AcceptLicense -Force"

  if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
  {
    Write-Host "Installing required module Poshtache"
    $sb = [scriptblock]::Create($installScript)
    Invoke-Command $sb
  }
  else 
  {
    $tempFile = New-TemporaryFile
    $tempFile.MoveTo($tempFile.FullName + ".ps1")

    Set-Content -Path $tempFile -Value $installScript

    Write-Host "Launching an new, elevated, PowerShell session in order to install Poshstache, a required module"
    Start-Process (Get-PSHostProcessInfo | where-object {$_.ProcessId -eq $PID}).ProcessName -verb runas -ArgumentList "-file $($tempFile.FullName)" -Wait
  }
}

Write-Host "Required module Poshtache is installed"

Import-Module Poshstache

$folders = @{
  out = join-path -path "." -childPath "generated"
  template = join-path -path "." -ChildPath "templates"
  obj = join-path -path "." -childPath "obj"
}

$files = @{
  eventsJson = ".\events.json"
  eventIdsHelper = @{
    out = {join-path $folders.out -childPath "CommonLoggingLibrary\EventIds\Helper.cs" }
    json = {join-path $folders.obj -childPath "CommonLoggingLibrary\EventIds\Helper.json" }
    template = {join-path $folders.template -childPath "eventIds.helper.tmpl" }
  }
  eventIdsLevel = @{
    out      = { param([Parameter(Mandatory=$true)]$level) Join-Path $folders.out -childPath "CommonLoggingLibrary\EventIds\$level.cs" }
    json      = { param([Parameter(Mandatory=$true)]$level) Join-Path $folders.obj -childPath "CommonLoggingLibrary\EventIds\$level.json" }
    template = { join-path $folders.template -childPath "eventIds.level.tmpl" }
  }
  Category = @{
    out      = { param([Parameter(Mandatory=$true)]$category) Join-Path $folders.out -childPath "CommonLoggingLibrary\$category.cs" }
    json      = { param([Parameter(Mandatory=$true)]$category) Join-Path $folders.obj -childPath "CommonLoggingLibrary\$category.json" }
    template = { join-path $folders.template -childPath "category.tmpl" }
  }
}

Get-ChildItem -path $folders.out "*.cs" -Recurse | remove-item

function Script:New-Folder
{
  param([Parameter(Mandatory=$true)]$destination)

  $f = Split-Path $destination

  if (Test-Path $f)
  {
    Write-Information "$f already created"
  }
  else 
  {
    Write-Information "$f does not exist, create"
    new-item -Path $f -ItemType Directory -Force
  }
}

$data = Get-Content -path $files.eventsJson | convertFrom-json -AsHashtable

# -------------------------------
Write-Host "1/3 EventIds/helper.cs"
<#
    /// <summary>Referenced by <see cref="LowLevel.Application_Starting/>, raised by <see cref="Application.Starting"/></summary>
    internal const int APPLICATION_STARTING = 101;
    
    {{#ids}}
    /// <summary>Referenced by <see cref="{{referencedByEventClass}}.{{referencedByEventDeclaration}}"/>, raised by <see cref="{{raisedByCategory}}.{{raisedByMethod}}"/></summary>
    internal const int {{name}} = {{id}};
    {{/ids}}
#>
$o = @{ids=[System.Collections.ArrayList]::new()}

foreach($key in $data.Ids.Keys | sort-object)
{
  <#
    $key = $d.IDs.Keys | sort-object | select-object -first 1
    $key
  #>
  $e = $data.Ids."$key"
  <#
    $eventId
  #>

  if ("$key" -ne "$($e.EventId)")
  {
    Write-Error "Key: $key -ne EventId $($e.EventId)"
    break
  }

  $o.ids.Add([PSCustomObject][ordered]@{
    eventId = $e.EventId
    name = "$($e.FullyQualifiedMethodName.ToUpper())"
    message = $e.Message
    referencedByEventClass = $e.EventClass
    referencedByEventDeclaration = $e.FullyQualifiedMethodName
    raisedByCategory = $e.Category
    raisedByMethod = $e.Method
    id = [int]$e.EventId
  }) | Out-Null
}

New-Folder -destination (& $files.eventIdsHelper.out)
New-Folder -destination (& $files.eventIdsHelper.json)

$json = $o | ConvertTo-Json -Depth 3
$json | set-content (& $files.eventidsHelper.json)

$PoshSplat = @{
  InputFile = & $files.eventIdsHelper.template
  ParametersObject = $json
}
$OutSplat = @{
  FilePath = & $files.eventIdsHelper.out 
  Encoding = "utf8BOM"
}
ConvertTo-PoshstacheTemplate @PoshSplat | out-file @OutSplat

# -------------------------------
Write-Host "2/3 EventIds.level.cs"

<#
  /// <summary>
  /// Low-level lifecycle related app events like Start, Pause, Stop, reading Configuration/Settings, Dependency initialization - Application plumbing, no intervention required by anyone
  /// </summary>
  public static class LowLevel
  {
    /// <summary>
    /// .  Used in the raising of Event ID <see cref="Helper.APPLICATION_STARTING">101</see> To raise this Event, use method <see cref="Application.Starting"/>
    /// </summary>
    public static EventId Application_Starting => new(Helper.APPLICATION_STARTING, nameof(Application.Starting));
  }

  /// <summary>
  /// {{no}}00 - {{description}}
  /// </summary>
  public static class {{name}}
  {
    {{#ids}}
    /// <summary>
    /// {{description}}.  Used in the raising of Event ID <see cref="Helper.{{constant}}">{{eventId}}</see> To raise this Event, use method <see cref="{{category}}.{{method}}"/>
    /// </summary>
    public static EventId {{fullyQualifiedMethodName}} => new(Helper.{{constant}}, nameof({{category}}.{{method}}));
    {{/ids}}


#>

foreach($key in $d.LogClass.Keys)
{

  <#
    $key = $d.LogClass.Keys | select-object -first 1
    $key
  #>

  $class = $d.LogClass."$key"
  <#
    $class
  #>
  Write-Host "  $key"

  $o = @{
    summary = $class.Summary
    name = $class.Name
    no = $class.No
    ids = [System.Collections.ArrayList]::new()
  }

  foreach($e in $data.Ids.Values | where-object {$_.EventClass -eq "$key"} | sort-object EventId)
  {
    <#
      $e = $data.Ids.Values | where-object {$_.EventClass -eq "$key"} | sort-object EventId | select-object -first 1
      $e
    #>

    $o.ids.Add([PSCustomObject]@{
      eventId = $e.EventId
      summary = $e.Summary
      remarks = $e.Remarks
      fullyQualifiedMethodName = $e.FullyQualifiedMethodName
      constant = $e.FullyQualifiedMethodName.ToUpper()
      category = $e.Category
      method = $e.Method
    }) | Out-Null
  }

  New-Folder -destination (& $files.eventIdsLevel.out -level $class.Name)
  New-Folder -destination (& $files.eventIdsLevel.json -level $class.Name)

  $json = $o | ConvertTo-Json -Depth 3
  $json | set-content (& $files.eventIdsLevel.out -level $class.Name)

  $PoshSplat = @{
    InputFile = (& $files.eventIdsLevel.template)
    ParametersObject = $json
  }
  $OutSplat = @{
    FilePath = (& $files.eventIdsLevel.out -level $class.Name)
    Encoding = "utf8BOM"
  }
  ConvertTo-PoshstacheTemplate @PoshSplat | out-file @OutSplat

}

Write-Host "3/3 Category.cs"

foreach($key in $d.Categories.Keys)
{
  <#
    $key = $d.Categories.Keys | select-object -first 1
    $key = "Application"
    $key
  #>
  Write-Host "  $key"

  $category = $d.Categories."$key"
  <#
    $category
  #>

  $o = @{
    name = $category.Name
    summary = $category.Summary
    methods = [System.Collections.ArrayList]::new()
  }

  foreach($method in $data.Ids.Values | where-object {$_.Category -eq "$Key"})
  {
    <#
      $method = $data.Ids.Values | where-object {$_.Category -eq "$Key"} | select-object -first 1
      $method = $data.Ids.Values | where-object {$_.Category -eq "$Key"} | where-object {$_.Arguments.count -gt 0} | select-object -first 1
      $method = "External_Calling"
      $method = "Application_Starting"
    #>

    $arguments = [System.Collections.ArrayList]::new()
    $prefix = ""
    foreach($argument in $method.Arguments)
    {
      <#
        $argument = $method.Arguments | select-object -first 1
        $argument
      #>
      $arguments.Add([PSCustomObject]@{
        name = $argument.Name
        valueType = $argument.ValueType
        summary = $argument.Summary
        prefix = $prefix
      }) | Out-Null

      $prefix = ", "
    }

    $o.methods.Add([PSCustomObject]@{
      privateName = "_$($method.Method.ToLower())"
      name = $method.Method
      logLevel = $method.LogLevel
      eventClass = $method.EventClass
      eventId = $method.EventId
      fullyQualifiedMethodName = $method.FullyQualifiedMethodName
      eventIdConstantDeclaration = $method.FullyQualifiedMethodName.ToUpper()
      message = $method.Message
      summary = $method.Summary
      remarks = $method.Remarks
      arguments = $arguments
      withArguments = $arguments.Count -gt 0
    }) | Out-Null


  }

  New-Folder -destination (& $files.Category.out -category $category.Name)
  New-Folder -destination (& $files.Category.json -category $category.Name)

  $json = $o | ConvertTo-Json -Depth 4
  $json | set-content (& $files.Category.json -category $category.Name)

  $PoshSplat = @{
    InputFile = (& $files.Category.template)
    ParametersObject = $json
  }
  $OutSplat = @{
    FilePath = (& $files.Category.out -category $category.Name)
    Encoding = "utf8BOM"
  }
  ConvertTo-PoshstacheTemplate @PoshSplat | out-file @OutSplat 
}

Start-Process (Join-path -path $folders.out -ChildPath "CommonLoggingLibrary\")