function Test-TWAAuthIsSet{
    
    if($Global:TWACredentials)
    {
        return $true;
    }
    else
    {
        return $false;
    }   
}
