from ranger.api.commands import Command
import subprocess
# import re
from collections import deque
import os
from ranger.container.file import File
from ranger.ext.get_executables import get_executables
from ranger.core.loader import CommandLoader


class paste_as_root(Command):
	def execute(self):
		if self.fm.do_cut:
			self.fm.execute_console('shell sudo mv %c .')
		else:
			self.fm.execute_console('shell sudo cp -r %c .')



# fasd command with ranger
#   ranger Wiki : https://github.com/ranger/ranger/wiki/Commands
#   fasd : https://github.com/clvv/fasd


class empty(Command):
    """:empty

    Empties the trash directory ~/.Trash
    """

    def execute(self):
        self.fm.run("rm -rf /home/myname/.Trash/{*,.[^.]*}")


class extracthere(Command):
    def execute(self):
        """ Extract copied files to current directory """
        copied_files = tuple(self.fm.copy_buffer)

        if not copied_files:
            return

        def refresh(_):
            cwd = self.fm.get_directory(original_path)
            cwd.load_content()

        one_file = copied_files[0]
        cwd = self.fm.thisdir
        original_path = cwd.path
        au_flags = ['-X', cwd.path]
        au_flags += self.line.split()[1:]
        au_flags += ['-e']

        self.fm.copy_buffer.clear()
        self.fm.cut_buffer = False
        if len(copied_files) == 1:
            descr = "extracting: " + os.path.basename(one_file.path)
        else:
            descr = "extracting files from: " + \
            	os.path.basename(one_file.dirname)
        obj = CommandLoader(args=['aunpack'] + au_flags
                            + [f.path for f in copied_files], descr=descr)

        obj.signal_bind('after', refresh)
        self.fm.loader.add(obj)


class compress(Command):
    def execute(self):
        """ Compress marked files to current directory """
        cwd = self.fm.thisdir
        marked_files = cwd.get_selection()

        if not marked_files:
            return

        def refresh(_):
            cwd = self.fm.get_directory(original_path)
            cwd.load_content()

        original_path = cwd.path
        parts = self.line.split()
        au_flags = parts[1:]

        descr = "compressing files in: " + os.path.basename(parts[1])
        obj = CommandLoader(args=['apack'] + au_flags +
                            [os.path.relpath(f.path, cwd.path) for f in marked_files], descr=descr)

        obj.signal_bind('after', refresh)
        self.fm.loader.add(obj)

    def tab(self):
        """ Complete with current folder name """

        extension = ['.zip', '.tar.gz', '.rar', '.7z']
        return ['compress ' + os.path.basename(self.fm.thisdir.path) + ext for ext in extension]

# custom commands

class mkcd(Command):
    """
    :mkcd <dirname>

    Creates a directory with the name <dirname> and enters it.
    """

    def execute(self):
        from os.path import join, expanduser, lexists
        from os import makedirs
        import re

        dirname = join(self.fm.thisdir.path, expanduser(self.rest(1)))
        if not lexists(dirname):
            makedirs(dirname)

            match = re.search('^/|^~[^/]*/', dirname)
            if match:
                self.fm.cd(match.group(0))
                dirname = dirname[match.end(0):]

            for m in re.finditer('[^/]+', dirname):
                s = m.group(0)
                if s == '..' or (s.startswith('.') and not self.fm.settings['show_hidden']):
                    self.fm.cd(s)
                else:
                    ## We force ranger to load content before calling `scout`.
                    self.fm.thisdir.load_content(schedule=False)
                    self.fm.execute_console('scout -ae ^{}$'.format(s))
        else:
            self.fm.notify("file/directory exists!", bad=True)

class toggle_flat(Command):
    """
    :toggle_flat

    Flattens or unflattens the directory view.
    """

    def execute(self):
        if self.fm.thisdir.flat == 0:
            self.fm.thisdir.unload()
            self.fm.thisdir.flat = -1
            self.fm.thisdir.load_content()
        else:
            self.fm.thisdir.unload()
            self.fm.thisdir.flat = 0
            self.fm.thisdir.load_content()

class up(Command):
    def execute(self):
        if self.arg(1):
            scpcmd = ["scp", "-r"]
            scpcmd.extend([f.realpath for f in self.fm.thistab.get_selection()])
            scpcmd.append(self.arg(1))
            self.fm.execute_command(scpcmd)
            self.fm.notify("Uploaded!")


    def tab(self, tabnum):
        import os.path
        try:
            import paramiko
        except ImportError:
            """paramiko not installed"""
            return

        try:
            with open(os.path.expanduser("~/.ssh/config")) as file:
                paraconf = paramiko.SSHConfig()
                paraconf.parse(file)
        except IOError:
            """cant open ssh config"""
            return

        hosts = sorted(list(paraconf.get_hostnames()))
        # remove any wildcard host settings since they're not real servers
        hosts.remove("*")
        query = self.arg(1) or ''
        matching_hosts = []
        for host in hosts:
            if host.startswith(query):
                matching_hosts.append(host)
        return (self.start(1) + host + ":" for host in matching_hosts)

class fasd(Command):
    """
    :fasd

    Jump to directory using fasd
    """
    def execute(self):
        args = self.rest(1).split()
        if args:
            directories = self._get_directories(*args)
            if directories:
                self.fm.cd(directories[0])
            else:
                self.fm.notify("No results from fasd", bad=True)

    def tab(self, tabnum):
        start, current = self.start(1), self.rest(1)
        for path in self._get_directories(*current.split()):
            yield start + path

    @staticmethod
    def _get_directories(*args):
        import subprocess
        output = subprocess.check_output(["fasd", "-dl"] + list(args), universal_newlines=True)
        dirs = output.strip().split("\n")
        dirs.sort(reverse=True)  # Listed in ascending frecency
        return dirs

class fasd_dir(Command):
    def execute(self):
        import subprocess
        import os.path
        fzf = self.fm.execute_command("fasd -dl | grep -iv cache | fzf 2>/dev/tty", universal_newlines=True, stdout=subprocess.PIPE)
        stdout, stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.rstrip('\n'))
            print(fzf_file)
            if os.path.isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)


class fzf_select(Command):
    """
    :fzf_select

    Find a file using fzf.

    With a prefix argument select only directories.

    See: https://github.com/junegunn/fzf
    """

    def execute(self):
        import subprocess
        import os.path
        if self.quantifier:
            # match only directories
            command = "find -L . \( -path '*/\.*' -o -fstype 'dev' -o -fstype 'proc' \) -prune \
            -o -type d -print 2> /dev/null | sed 1d | cut -b3- | fzf +m --reverse --header='Jump to file'"
        else:
            # match files and directories
            command = "find -L . \( -path '*/\.*' -o -fstype 'dev' -o -fstype 'proc' \) -prune \
            -o -print 2> /dev/null | sed 1d | cut -b3- | fzf +m --reverse --header='Jump to filemap <C-f> fzf_select'"
        fzf = self.fm.execute_command(
            command, universal_newlines=True, stdout=subprocess.PIPE)
        stdout, stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.rstrip('\n'))
            if os.path.isdir(fzf_file):
                self.fm.cd(fzf_file)
            else:
                self.fm.select_file(fzf_file)

class fd_search(Command):
    """
    :fd_search [-d<depth>] <query>
    Executes "fd -d<depth> <query>" in the current directory and focuses the
    first match. <depth> defaults to 1, i.e. only the contents of the current
    directory.

    See https://github.com/sharkdp/fd
    """

    SEARCH_RESULTS = deque()

    def execute(self):
        import re
        import subprocess
        from ranger.ext.get_executables import get_executables

        self.SEARCH_RESULTS.clear()

        if 'fdfind' in get_executables():
            fd = 'fdfind'
        elif 'fd' in get_executables():
            fd = 'fd'
        else:
            self.fm.notify("Couldn't find fd in the PATH.", bad=True)
            return

        if self.arg(1):
            if self.arg(1)[:2] == '-d':
                depth = self.arg(1)
                target = self.rest(2)
            else:
                depth = '-d1'
                target = self.rest(1)
        else:
            self.fm.notify(":fd_search needs a query.", bad=True)
            return

        hidden = ('--hidden' if self.fm.settings.show_hidden else '')
        exclude = "--no-ignore-vcs --exclude '.git' --exclude '*.py[co]' --exclude '__pycache__'"
        command = '{} --follow {} {} {} --print0 {}'.format(
            fd, depth, hidden, exclude, target
        )
        fd = self.fm.execute_command(command, universal_newlines=True, stdout=subprocess.PIPE)
        stdout, _ = fd.communicate()

        if fd.returncode == 0:
            results = filter(None, stdout.split('\0'))
            if not self.fm.settings.show_hidden and self.fm.settings.hidden_filter:
                hidden_filter = re.compile(self.fm.settings.hidden_filter)
                results = filter(lambda res: not hidden_filter.search(os.path.basename(res)), results)
            results = map(lambda res: os.path.abspath(os.path.join(self.fm.thisdir.path, res)), results)
            self.SEARCH_RESULTS.extend(sorted(results, key=str.lower))
            if len(self.SEARCH_RESULTS) > 0:
                self.fm.notify('Found {} result{}.'.format(len(self.SEARCH_RESULTS),
                                                           ('s' if len(self.SEARCH_RESULTS) > 1 else '')))
                self.fm.select_file(self.SEARCH_RESULTS[0])
            else:
                self.fm.notify('No results found.')

class fd_next(Command):
    """
    :fd_next
    Selects the next match from the last :fd_search.
    """

    def execute(self):
        if len(fd_search.SEARCH_RESULTS) > 1:
            fd_search.SEARCH_RESULTS.rotate(-1)  # rotate left
            self.fm.select_file(fd_search.SEARCH_RESULTS[0])
        elif len(fd_search.SEARCH_RESULTS) == 1:
            self.fm.select_file(fd_search.SEARCH_RESULTS[0])

class fd_prev(Command):
    """
    :fd_prev
    Selects the next match from the last :fd_search.
    """

    def execute(self):
        if len(fd_search.SEARCH_RESULTS) > 1:
            fd_search.SEARCH_RESULTS.rotate(1)  # rotate right
            self.fm.select_file(fd_search.SEARCH_RESULTS[0])
        elif len(fd_search.SEARCH_RESULTS) == 1:
            self.fm.select_file(fd_search.SEARCH_RESULTS[0])

class fzf_rga_documents_search(Command):
    """
    :fzf_rga_search_documents
    Search in PDFs, E-Books and Office documents in current directory.
    Allowed extensions: .epub, .odt, .docx, .fb2, .ipynb, .pdf.

    Usage: fzf_rga_search_documents <search string>
    """
    def execute(self):
        if self.arg(1):
            search_string = self.rest(1)
        else:
            self.fm.notify("Usage: fzf_rga_search_documents <search string>", bad=True)
            return

        import subprocess
        import os.path
        from ranger.container.file import File
        command="rga '%s' . --rga-adapters=pandoc,poppler | fzf +m | awk -F':' '{print $1}'" % search_string
        fzf = self.fm.execute_command(command, universal_newlines=True, stdout=subprocess.PIPE)
        stdout, stderr = fzf.communicate()
        if fzf.returncode == 0:
            fzf_file = os.path.abspath(stdout.rstrip('\n'))
            self.fm.execute_file(File(fzf_file))

# class ag(Command):
#     """:ag 'regex'
#     Looks for a string in all marked paths or current dir
#     """
#     editor = os.getenv('EDITOR') or 'vim'
#     acmd = 'ag --smart-case --group --color --hidden'  # --search-zip
#     qarg = re.compile(r"""^(".*"|'.*')$""")
#     patterns = []
#     # THINK:USE: set_clipboard on each direct ':ag' search? So I could find in vim easily

#     def _sel(self):
#         d = self.fm.thisdir
#         if d.marked_items:
#             return [f.relative_path for f in d.marked_items]
#         # WARN: permanently hidden files like .* are searched anyways
#         #   << BUG: files skipped in .agignore are grep'ed being added on cmdline
#         if d.temporary_filter and d.files_all and (len(d.files_all) != len(d.files)):
#             return [f.relative_path for f in d.files]
#         return []

#     def _arg(self, i=1):
#         if self.rest(i):
#             ag.patterns.append(self.rest(i))
#         return ag.patterns[-1] if ag.patterns else ''

#     def _quot(self, patt):
#         return patt if ag.qarg.match(patt) else shell_quote(patt)

#     def _bare(self, patt):
#         return patt[1:-1] if ag.qarg.match(patt) else patt

#     def _aug_vim(self, iarg, comm='Ag'):
#         if self.arg(iarg) == '-Q':
#             self.shift()
#             comm = 'sil AgSet def.e.literal 1|' + comm
#         # patt = self._quot(self._arg(iarg))
#         patt = self._arg(iarg)  # No need to quote in new ag.vim
#         # FIXME:(add support)  'AgPaths' + self._sel()
#         cmd = ' '.join([comm, patt])
#         cmdl = [ag.editor, '-c', cmd, '-c', 'only']
#         return (cmdl, '')

#     def _aug_sh(self, iarg, flags=[]):
#         cmdl = ag.acmd.split() + flags
#         if iarg == 1:
#             import shlex
#             cmdl += shlex.split(self.rest(iarg))
#         else:
#             # NOTE: only allowed switches
#             opt = self.arg(iarg)
#             while opt in ['-Q', '-w']:
#                 self.shift()
#                 cmdl.append(opt)
#                 opt = self.arg(iarg)
#             # TODO: save -Q/-w into ag.patterns =NEED rewrite plugin to join _aug*()
#             patt = self._bare(self._arg(iarg))  # THINK? use shlex.split() also/instead
#             cmdl.append(patt)
#         if '-g' not in flags:
#             cmdl += self._sel()
#         return (cmdl, '-p')

#     def _choose(self):
#         if self.arg(1) == '-v':
#             return self._aug_vim(2, 'Ag')
#         elif self.arg(1) == '-g':
#             return self._aug_vim(2, 'sil AgView grp|Ag')
#         elif self.arg(1) == '-l':
#             return self._aug_sh(2, ['--files-with-matches', '--count'])
#         elif self.arg(1) == '-p':  # paths
#             return self._aug_sh(2, ['-g'])
#         elif self.arg(1) == '-f':
#             return self._aug_sh(2)
#         elif self.arg(1) == '-r':
#             return self._aug_sh(2, ['--files-with-matches'])
#         else:
#             return self._aug_sh(1)

#     def _catch(self, cmd):
#         from subprocess import check_output, CalledProcessError
#         try:
#             out = check_output(cmd)
#         except CalledProcessError:
#             return None
#         else:
#             return out[:-1].decode('utf-8').splitlines()

#     # DEV
#     # NOTE: regex becomes very big for big dirs
#     # BAD: flat ignores 'filter' for nested dirs
#     def _filter(self, lst, thisdir):
#         # filter /^rel_dir/ on lst
#         # get leftmost path elements
#         # make regex '^' + '|'.join(re.escape(nm)) + '$'
#         thisdir.temporary_filter = re.compile(file_with_matches)
#         thisdir.refilter()

#         for f in thisdir.files_all:
#             if f.is_directory:
#                 # DEV: each time filter-out one level of files from lst
#                 self._filter(lst, f)

#     def execute(self):
#         cmd, flags = self._choose()
#         # self.fm.notify(cmd)
#         # TODO:ENH: cmd may be [..] -- no need to shell_escape
#         if self.arg(1) != '-r':
#             self.fm.execute_command(cmd, flags=flags)
#         else:
#             self._filter(self._catch(cmd))

#     def tab(self):
#         # BAD:(:ag <prev_patt>) when input alias ':agv' and then <Tab>
#         #   <= EXPL: aliases expanded before parsing cmdline
#         cmd = self.arg(0)
#         flg = self.arg(1)
#         if flg[0] == '-' and flg[1] in 'flvgprw':
#             cmd += ' ' + flg
#         return ['{} {}'.format(cmd, p) for p in reversed(ag.patterns)]

class show_files_in_finder(Command):
    """
    :show_files_in_finder

    Present selected files in finder
    """

    def execute(self):
        import subprocess
        files = ",".join(['"{0}" as POSIX file'.format(file.path) for file in self.fm.thistab.get_selection()])
        reveal_script = "tell application \"Finder\" to reveal {{{0}}}".format(files)
        activate_script = "tell application \"Finder\" to set frontmost to true"
        script = "osascript -e '{0}' -e '{1}'".format(reveal_script, activate_script)
        self.fm.notify(script)
        subprocess.check_output(["osascript", "-e", reveal_script, "-e", activate_script])

# class sk_select(Command):
#     def execute(self):
#         import subprocess
#         from ranger.ext.get_executables import get_executables
#
#         if 'sk' not in get_executables():
#             self.fm.notify('Could not find skim', bad=True)
#             return
#
#         sk = self.fm.execute_command('sk ',universal_newlines=True, stdout=subprocess.PIPE)
#         stdout, _ = sk.communicate()
#         if sk.returncode == 0:
#             selected = os.path.abspath(stdout.strip())
#             if os.path.isdir(selected):
#                 self.fm.cd(selected)
#             else:
#                 self.fm.select_file(selected)

# class tmsu_tag(Command):
#     """:tmsu_tag
#
#     Tags the current file with tmsu
#     """
#
#     def execute(self):
#         cf = self.fm.thisfile
#
#         self.fm.run("tmsu tag \"{0}\" {1}".format(cf.basename, self.rest(1)))

# class YankContent(Command):
#     """
#     Copy the content of image file and text file with xclip
#     """

#     def execute(self):
#         if 'xclip' not in get_executables():
#             self.fm.notify('xclip is not found.', bad=True)
#             return

#         arg = self.rest(1)
#         if arg:
#             if not os.path.isfile(arg):
#                 self.fm.notify('{} is not a file.'.format(arg))
#                 return
#             file = File(arg)
#         else:
#             file = self.fm.thisfile
#             if not file.is_file:
#                 self.fm.notify('{} is not a file.'.format(file.relative_path))
#                 return

#         relative_path = file.relative_path
#         cmd = ['xclip', '-selection', 'clipboard']
#         if not file.is_binary():
#             with open(file.path, 'rb') as fd:
#                 subprocess.check_call(cmd, stdin=fd)
#         elif file.image:
#             cmd += ['-t', file.mimetype, file.path]
#             subprocess.check_call(cmd)
#             self.fm.notify('Content of {} is copied to x clipboard'.format(relative_path))
#         else:
#             self.fm.notify('{} is not an image file or a text file.'.format(relative_path))

#     def tab(self, tabnum):
#         return self._tab_directory_content()