echo "Users for AD Verification" ; 
echo "============ LIST ============" ; 
cat .\PD.txt | ForEach-Object {echo $_} ; 
echo "============ PROCESS ============" ;
echo "Executing Active Directory Verification" ; 

$list = cat .\PD.txt; 

Get-ADUser -filter * -properties EmailAddress -SearchBase 'DC=del-valle,DC=k12,DC=tx,DC=us'| select-object Name, EmailAddress | select-string $list
