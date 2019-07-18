#get STIG
$stig = ".\Seed_XCCDF\U_MS_OfficeSystem_2013_STIG_V1R8_Manual-xccdf.xml"

$date 
$title
$description

$groupID 
$groupCount 


#check for STIG and load.
 if(Test-Path $stig){
     
    [xml]$manualStig = Get-Content -Path $stig -ErrorAction SilentlyContinue
 }
 else {
    throw [System.IO.FileNotFoundException] " Error opening the STIG file."
    #Write-Host "Error opening the computer name list"
 }



$groups = $manualStig.GetElementsByTagName("Group")
 
   
foreach ($group in $groups){
   $content =  $group.GetElementsByTagName("check-content").InnerXml
   findValues $content  $group.id
}

   function findValues ([string]$content,[string] $groupID) {
      
      Write-Host "Checking group id = $groupID" -ForegroundColor Red

      $start = $content.IndexOf("key:") 

      if($? -lt 0){
         
         Write-host "$group Problem finding the key string"
         
      }
      else {
        
      $start = $start + 4 
         
      $end = $content.IndexOf("Criteria")

      $endValue = $content.IndexOf(",",$end)


      $key = $content.Substring($start,$end - $start)
      $value = $content.Substring($end,  $endValue - $end)
      $start = $value.IndexOf("value") + 5
       $end = $value.IndexOf(" is") #add space
       $regKey =  $value.Substring($start,$end - $start)

       $regWord = $value.Substring($value.IndexOf("=") + 1)
      
      checkRegistry $key.Trim() $regKey.ToLower().Trim() $regWord  
         
      }

   }
   function checkRegistry([string]$key, [string]$regKey, [string]$regword ){

      Write-host "Key = " $Key
      Write-host "regKey = " $regKey
      Write-Host "regword = " $regword 

      $newKey = $Key.Insert(4,":")  #insert : to the registry path

      #Write-Host "new key = $newkey"
      if(Test-Path -Path  $newKey){
          $check = Get-Item  "$newKey"

          if ($check.Property.Contains($regKey))
          {
             Write-Host "regkey is there " $regKey
  
             if( $check.GetValue($regKey) -eq $regword){
                 Write-host "$regKey equals $regword . The system is compliant"
             } 
             else{
                 Write-host "$regKey  doesn't equals $regword . The system is  not compliant"
             }     
  
          }
          else{
             Write-Host "$regKey is missing.  The system is not compliant"
          }
      }
      else{
         Write-Host "the key: $newKey doesn't exist"
      }
   }

  
 
   

   
   <#


<#
$scc = New-Object -ComObject UIResource.UIResourceMgr

$tt = $scc.GetAvailableScripts()

$tt.Count
$cache = $scc.GetCacheInfo()

$cache.TotalSize

Get-HotFix | Select-Object HotFixID

#>
