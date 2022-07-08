set-location $PSScriptRoot

<#
$ErrorActionPreference = "Inquire"
#>

if (!(Get-Module Poshstache))
{
  Write-Warning "Poshtache PowerShell module not found, need to install it."
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

    Write-Host "You have the option to install Poshtache for you only or globally, globally will prompt you to accept UAC"

    $title = "Do you want to install Poshtache locally or globally?"
    $prompt = "Enter your choice"
    $choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&You", "&All Users", "&Cancel")    
    $default = 1
    $choice = $host.UI.PromptForChoice($title, $prompt, $choices, $default)

    switch($choice)
    {
      0 { 
          Install-Module -Name Poshstache -Scope CurrentUser -AcceptLicense -Force
          break
        }
      1 {
          $tempFile = New-TemporaryFile
          $tempFile.MoveTo($tempFile.FullName + ".ps1")
          Set-Content -Path $tempFile -Value $installScript    
          Write-Host "Launching an new, elevated, PowerShell session in order to install Poshstache, a required module"
          Start-Process (Get-PSHostProcessInfo | where-object {$_.ProcessId -eq $PID}).ProcessName -verb runas -ArgumentList "-file $($tempFile.FullName)" -Wait
          break
      }
      2 {
        Write-Host "Exiting"
        return
      }
    }
  }
}

Write-Host "Required module Poshtache is installed"

Import-Module Poshstache

$folders = @{
  src = join-path -path "." -ChildPath "src"
  lib = join-path -path "." -ChildPath "CommonLoggingLibrary"
  referenceApps = join-path "." -ChildPath "src"
  template = join-path -path "." -ChildPath "templates"
  obj = join-path -path "." -childPath "obj"
}

$files = @{
  eventsJson = ".\events.json"
  eventIdsConstants = @{
    out = {join-path $folders.lib -childPath "EventIds\Constants.cs" }
    json = {join-path $folders.obj -childPath "EventIds\Constants.json" }
    template = {join-path $folders.template -childPath "eventIds.constants.tmpl" }
  }
  eventIdsLevel = @{
    out      = { param([Parameter(Mandatory=$true)]$level) Join-Path $folders.lib -childPath "EventIds\$level.cs" }
    json      = { param([Parameter(Mandatory=$true)]$level) Join-Path $folders.obj -childPath "EventIds\$level.json" }
    template = { join-path $folders.template -childPath "eventIds.level.tmpl" }
  }
  Category = @{
    out      = { param([Parameter(Mandatory=$true)]$category) Join-Path $folders.lib -childPath "$category.cs" }
    json      = { param([Parameter(Mandatory=$true)]$category) Join-Path $folders.obj -childPath "$category.json" }
    template = { join-path $folders.template -childPath "category.tmpl" }
  }
  solution = join-path -path $folders.src -ChildPath "CommonLoggingLibrary.sln"
  library = join-path -path $folders.lib -ChildPath "CommonLoggingLibrary.csproj"
}

if (!(Test-Path -path $files.library))
{
  & dotnet new classlib -o (split-path $files.library) -n (split-path $files.library -LeafBase)
  & dotnet sln $files.solution add $files.library  
  & dotnet add $files.library package "Microsoft.Extensions.Logging"

  & dotnet restore $files.solution
}

Write-Host "Clean *.cs files"
Get-ChildItem -path $folders.lib "*.cs" -Recurse | remove-item

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
} # Script:New-Folder

function Script:Get-RelatedIngEd
{
  param($data, $eventId)

  $relatedIngEd = $null

  $rie = $data.Related.Ing_Ed | where-object {$_.Ing -eq "$eventId" -or $_.Ed -eq "$eventId"}

  if ($rie)
  {
    $itemIng = $data.Ids."$($rie.Ing)"
    $itemEd = $data.Ids."$($rie.Ed)"

    $relatedIngEd = [ordered]@{
      ing = [ordered]@{
        eventId = $rie.Ing
        name = "$($itemIng.FullyQualifiedMethodName.ToUpper())"
        raisedByCategory = $itemIng.Category
        raisedByMethod = $itemIng.Method
      }
      ed = [ordered]@{
        eventId = $rie.Ed
        name = "$($itemEd.FullyQualifiedMethodName.ToUpper())"
        raisedByCategory = $itemEd.Category
        raisedByMethod = $itemEd.Method
      }
      fails = [System.Collections.ArrayList]::new()
    }

    foreach($failId in $rie.Fails)
    {
      $item = $data.Ids."$($failId)"

      $relatedIngEd.Fails.Add(@{
        eventId = $failId
        name = "$($item.FullyQualifiedMethodName.ToUpper())"
        raisedByCategory = $item.Category
        raisedByMethod = $item.Method
    
      }) | out-null
    }
  }

  return $relatedIngEd
} # function Script:Get-RelatedIngEd

function Script:ConvertTo-MustacheEventConstant
{
  param($data, $eventId)
  
  $relatedIngEd = Get-RelatedIngEd -data $data -eventId $eventId

  $e = $data.Ids."$eventId"
  
  $ret = [ordered]@{
    eventId = $e.EventId                                             # 101
    name = "$($e.FullyQualifiedMethodName.ToUpper())"                # internal const int APPLICATION_STARTING = 101;
    message = $e.Message                                             # Application is starting.  Args: {args}
    referencedByEventClass = $e.EventClass                           # <summary>101 - Referenced by Declaration <see cref="{{referencedByEventClass}}.{{referencedByEventDeclaration}}"/>, raised by method <see cref="{{raisedByCategory}}.{{raisedByMethod}}"/>
    referencedByEventDeclaration = $e.FullyQualifiedMethodName
    raisedByCategory = $e.Category
    raisedByMethod = $e.Method
    id = [int]$e.EventId
    relatedIngEd = $relatedIngEd
  } # function Script:ConvertTo-MustacheEventConstant

  return $ret
}

$data = Get-Content -path $files.eventsJson | convertFrom-json -AsHashtable

# -------------------------------
Write-Host "1/3 EventIds/Constants.cs"
$o = @{ids=[System.Collections.ArrayList]::new()}

foreach($key in $data.Ids.Keys | sort-object)
{
  <#
    $key = $data.Ids.Keys | sort-object | select-object -first 1
    $key = "101"
    $key = "201"
    $key
  #>

  $e = ConvertTo-MustacheEventConstant -data $data -eventId "$key"

  if ("$key" -ne "$($e.EventId)")
  {
    Write-Error "Key: $key -ne EventId $($e.EventId)"
    break
  }

  $o.ids.Add([PSCustomObject]$e) | Out-Null
}

New-Folder -destination (& $files.eventIdsConstants.out)
New-Folder -destination (& $files.eventIdsConstants.json)

$json = $o | ConvertTo-Json -Depth 7
$json | set-content (& $files.eventidsConstants.json)

$PoshSplat = @{
  InputFile = & $files.eventIdsConstants.template
  ParametersObject = $json
}
$OutSplat = @{
  FilePath = & $files.eventIdsConstants.out 
  Encoding = "utf8BOM"
}
ConvertTo-PoshstacheTemplate @PoshSplat | out-file @OutSplat

# -------------------------------
Write-Host "2/3 EventIds.level.cs"

foreach($key in $data.LogClass.Keys)
{

  <#
    $key = $data.LogClass.Keys | select-object -first 1
    $key
  #>

  $class = $data.LogClass."$key"
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

foreach($key in $data.Categories.Keys)
{
  <#
    $key = $data.Categories.Keys | select-object -first 1
    $key = "Application"
    $key
  #>
  Write-Host "  $key"

  $category = $data.Categories."$key"
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
      privateName = "_$($method.Method.substring(0,1).ToLower())$($method.Method.substring(1,$method.Method.Length-1))"
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

#Start-Process (split-path $files.library)
Start-Process $files.solution