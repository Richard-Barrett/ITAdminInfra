$users = & gam.exe print users query "orgUnitPath='/Students'"

foreach($user in $users){& gam update user $user password SomePassword changepassword on }
