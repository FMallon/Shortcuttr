#!/usr/bin/awk -f

####ssssssshhhhhhhhhhhiiiiiiiiiiiiiittttttttttttt########
BEGIN{
  FS = ";"
  Alias = ARGV[1]
  Cwd = ARGV[3]
  File = ARGV[3]

  print "recieved ", Alias, " & dir:", Cwd
}


{

  #print $1, " and ", $2
  #cwd or alias exists, exit status 1
  if ($1 == Alias || $2 == Cwd){
    exit 1
  }

}



END{
  
  exit 0

}
