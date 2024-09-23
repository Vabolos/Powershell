REM **********************************************************************************************************************************
REM AD Query to dump inactive computers and user accounts not active for longer then 6 weeks with a limit of 500 items to a textfile *
REM It appends to the log files so please clear them before a new run                                                                *
REM **********************************************************************************************************************************

dsquery computer -inactive 6 -limit 500		>> "C:\_Log\inactive_computers.txt"
dsquery user -inactive 6 -limit 500		>> "C:\_Log\inactive_users.txt"
