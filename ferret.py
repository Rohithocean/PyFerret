import sys
import os
import pyferret
import logging


def fer_main(arglist):
    """
    Interprets the traditional Ferret options given in arglist and starts
    pyferret appropriately.  If ${HOME}/.ferret exists, that script is then
    executed.  If a script filename is given, this routine calls pyferret.run
    with the ferret go command, the script filename and any arguments, and
    then exits.  Otherwise, this routine calls pyferret.run with no arguments
    in order to enter into Ferret command-line processing.
    """

    ferret_help_message = \
    """

    Usage:  ferret7  [-memsize <N>]  [-batch [<filename>]]  [-gif]  [-nojnl]  [-noverify]
                     [-version]  [-help]  [-script <scriptname> [ <scriptarg> ... ]]

       -memsize:   initialize the memory cache size to <N> (default 25.6) megafloats
                   (where 1 float = 4 bytes)
       -batch:     output directly to metafile <filename> (default "metafile.plt")
                   without X-Windows
       -gif:       output to GIF file without X-Windows only with the FRAME command
       -nojnl:     on startup don't open a journal file (can be turned on later with
                   SET MODE JOURNAL)
       -noverify:  on startup turn off verify mode (can be turned on later with
                   SET MODE VERIFY)
       -version:   print the Ferret header with version number and quit
       -help:      print this help message and quit
       -script:    execute the script <scriptname> with any arguments specified,
                   and exit (THIS MUST BE SPECIFIED LAST)

    """
    my_metaname = None
    my_memsize = 25.6
    my_journal = True
    my_verify = True
    script = None
    print_help = False
    just_exit = False
    # check is python debug logging is specified
    if "-pydebug" in arglist:
        logging.basicConfig(filename="ferret_pydebug.log", filemode="w", level=logging.DEBUG)
        my_logger = logging.getLogger("ferret")
    else:
        my_logger = None
    pyferret.my_logger = my_logger
    # debug logging
    if my_logger:
        my_logger.debug("fer_main(%s) called" % str(arglist))
    # To be compatible with traditional Ferret command-line options
    # (that are still supported), we need to parse the options by hand.
    try:
        k = 0
        while k < len(arglist):
            opt = arglist[k]
            if opt == "-memsize":
                k += 1
                try:
                    my_memsize = float(arglist[k])
                except:
                    raise ValueError, "a positive number must be given for a -memsize value"
                if my_memsize <= 0.0:
                    raise ValueError, "a positive number must be given for a -memsize value"
            elif opt == "-batch":
                my_metaname = "metafile.plt"
                k += 1
                # -batch has an optional argument
                try:
                    if arglist[k][0] != '-':
                        my_metaname = arglist[k]
                    else:
                        k -= 1
                except:
                    k -= 1
            elif opt == "-gif":
                my_metaname = ".gif"
            elif opt == "-nojnl":
                my_journal = False
            elif opt == "-noverify":
                my_verify = False
            elif opt == "-version":
                just_exit = True
                break
            elif opt == "-help":
                print_help = True
                break
            elif opt == "-script":
                k += 1
                try:
                    script = arglist[k:]
                    if my_logger:
                        my_logger.debug('found script list: %s' % str(script))
                    if len(script) == 0:
                        raise ValueError, "a script filename must be given for the -script value"
                except:
                    raise ValueError, "a script filename must be given for the -script value"
                break
            elif opt == "-pydebug":
                pass
            else:
                raise ValueError, "unrecognized option '%s'" % opt
            k += 1
    except ValueError, errmsg:
        # print the error message then mark for print the help message
        print >>sys.stderr, "\n%s" % errmsg
        print_help = True
    if print_help:
        # print the help message, then mark for exiting
        print >>sys.stderr, ferret_help_message
        just_exit = True
    if just_exit:
        # print the ferret header then exit completely
        if my_logger:
            my_logger.debug('calling pyferret.start(journal=False, verify=False, metaname=".gif") in the quit process')
        pyferret.start(journal=False, verify=False, metaname=".gif")
        if my_logger:
            my_logger.debug('calling pyferret.run("exit") to quit')
        pyferret.run("exit")
        raise SystemExit
    # debug logging
    if my_logger:
        my_logger.debug('calling pyferret.start(memsize=%s, journal=%s, verify=%s, metaname="%s")' % \
                        (str(my_memsize), str(my_journal), str(my_verify), str(my_metaname)) )
    # start ferret
    pyferret.start(memsize=my_memsize, journal=my_journal, verify=my_verify, metaname=my_metaname)
    # run the ${HOME}/.ferret script if it exists
    home_val = os.environ.get('HOME')
    if home_val:
        init_script = os.path.join(home_val, '.ferret')
        if os.path.exists(init_script):
            if my_logger:
                my_logger.debug('calling pyferret.run(\'go "%s"\')' % init_script)
            pyferret.run('go "%s"' % init_script)
    # if a command-line script is given, run the script and exit completely
    if script != None:
        script_line = " ".join(script)
        if my_logger:
            my_logger.debug('calling pyferret.run(\'go "%s"\')' % script_line)
        pyferret.run('go "%s"' % script_line)
        if my_logger:
            my_logger.debug('calling pyferret.run("exit") to quit')
        pyferret.run("exit")
        raise SystemExit
    # otherwise, go into Ferret command-line processing until "exit /topy"
    if my_logger:
        my_logger.debug('calling pyferret.run()')
    result = pyferret.run()
    return result


# if this is called as the main program, call fer_main appropriately
if __name__ == "__main__":
    (errval, errmsg) = fer_main(sys.argv[1:])
