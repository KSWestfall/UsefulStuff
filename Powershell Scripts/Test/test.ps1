$h = Get-Content H:\test.txt;
$h = $h.Replace(" ","");
$filter = 'Address="' + ($h -join """ or Address=""")+'"';
gwmi -Class Win32_processor -Filter $filter