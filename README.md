Play with K Framework
====

K Framework  
http://www.kframework.org/


Requirements
----
* `kcc` ... `kcc` provided by [rv-match](https://runtimeverification.com/match/) must be located at `$PATH`
    * I recommend *runtime verification*'s rv-match for ease of installation
* `afl-fuzz` ... Build AFL beforehand. I assume `afl-fuzz` is located at `~/bin/afl-2.52b/`


How to build
----
```shell
cd vuln-samples
make
```


Let's play with fuzzer!
----
In general, triage of crash inputs produced by fuzzers is hard because crash inputs tells existence of some crash bug but not tells root cause of the bug.

This demo illustrates how to handle crash inputs to see cause of bug using [rv-match](https://runtimeverification.com/match/) (also known as [c-semantics](https://github.com/kframework/c-semantics)).

### Step 0) About demo `simple-bof`
[simple-bof.c](vuln-samples/simple-bof.c) contains buffer overflow bug.

### Step 1) Check proof of vulnerability
```shell
cd vuln-samples
cat pov/simple-bof.input | ./simple-bof
```

We can observe stack smashing like this:

```
tomori@nao:~/project/play-with-kramework/vuln-samples$ cat pov/simple-bof.input | ./simple-bof
message length = 200
message = AAA%AAsAABAA$AAnAACAA-AA(AADAA;AA)AAEAAaAA0AAFAAbAA1AAGAAcAA2AAHAAdAA3AAIAAeAA4AAJAAfAA5AAKAAgAA6AALAAhAA7AAMAAiAA8AANAAjAA9AAOAAkAAPAAlAAQAAmAARAAoAASAApAATAAqAAUAArAAVAAtAAWAAuAAXAAvAAYAAwAAZAAxAAy
*** stack smashing detected ***: ./simple-bof terminated
Aborted
```

### Step 2) Perform fuzzing with AFL
Run AFL with following way.

```shell
rm -rf afl-output/simple-bof
~/bin/afl-2.52b/afl-fuzz -i fuzz/simple-bof/ -o afl-output/simple-bof ./simple-bof.afl
```

### Step 3) Invest crash input
Let's see what crash input causes with gdb-peda.

```
tomori@nao:~/project/play-with-kramework/vuln-samples$ gdb ./simple-bof
gdb-peda$ r < afl-output/simple-bof/crashes/id:000000,sig:06,src:000000,op:havoc,rep:16 
Starting program: /home/tomori/project/play-with-kramework/vuln-samples/simple-bof < afl-output/simple-bof/crashes/id:000000,sig:06,src:000000,op:havoc,rep:16
message length = 6666666
message = 6666666666666666e
*** stack smashing detected ***: /home/tomori/project/play-with-kramework/vuln-samples/simple-bof terminated

Program received signal SIGABRT, Aborted.

... snipped ...
Stopped reason: SIGABRT
0x00007ffff7a42428 in __GI_raise (sig=sig@entry=0x6) at ../sysdeps/unix/sysv/linux/raise.c:54
54	../sysdeps/unix/sysv/linux/raise.c: No such file or directory.
gdb-peda$ bt
#0  0x00007ffff7a42428 in __GI_raise (sig=sig@entry=0x6) at ../sysdeps/unix/sysv/linux/raise.c:54
#1  0x00007ffff7a4402a in __GI_abort () at abort.c:89
#2  0x00007ffff7a847ea in __libc_message (do_abort=do_abort@entry=0x1, 
    fmt=fmt@entry=0x7ffff7b9c49f "*** %s ***: %s terminated\n")
    at ../sysdeps/posix/libc_fatal.c:175
#3  0x00007ffff7b2615c in __GI___fortify_fail (msg=<optimized out>, 
    msg@entry=0x7ffff7b9c481 "stack smashing detected") at fortify_fail.c:37
#4  0x00007ffff7b26100 in __stack_chk_fail () at stack_chk_fail.c:28
#5  0x000000000040081c in main ()
#6  0x00007ffff7a2d830 in __libc_start_main (main=0x400726 <main>, argc=0x1, argv=0x7fffffffde68, 
    init=<optimized out>, fini=<optimized out>, rtld_fini=<optimized out>, 
    stack_end=0x7fffffffde58) at ../csu/libc-start.c:291
#7  0x0000000000400659 in _start ()

gdb-peda$ pdisas main 
Dump of assembler code for function main:
... snipped ...
   0x0000000000400803 <+221>:	mov    eax,0x0
   0x0000000000400808 <+226>:	mov    rcx,QWORD PTR [rbp-0x8]
   0x000000000040080c <+230>:	xor    rcx,QWORD PTR fs:0x28
   0x0000000000400815 <+239>:	je     0x40081c <main+246>
   0x0000000000400817 <+241>:	call   0x4005c0 <__stack_chk_fail@plt>
   0x000000000040081c <+246>:	leave  
   0x000000000040081d <+247>:	ret    
End of assembler dump.
```

We see that cause of crash is failure on `__stack_chk_fail()` (that is, stack smashing). But we can't see why stack smashing has happen.

### Step 4) Verify crash input with K Framework (c-semantics)
```shell
cat SOME_CRASH_INPUT | ./simple-bof.kcc
```

We see that cause of that stack smashing is buffer overflow (out-of-bounds write).

```
tomori@nao:~/project/play-with-kramework/vuln-samples$ cat afl-output/simple-bof/crashes/id\:000000\,sig\:06\,src\:000000\,op\:havoc\,rep\:16 | ./simple-bof.kcc
message length = 6666666
message = Trying to write outside the bounds of an object:
      > in fgets at simple-bof.c:17:9
        in main at simple-bof.c:17:9

    Undefined behavior (UB-EIO2):
        see C11 section 6.5.6:8 http://rvdoc.org/C11/6.5.6
        see C11 section J.2:1 items 47 and 49 http://rvdoc.org/C11/J.2
        see CERT-C section ARR30-C http://rvdoc.org/CERT-C/ARR30-C
        see CERT-C section ARR37-C http://rvdoc.org/CERT-C/ARR37-C
        see CERT-C section MEM35-C http://rvdoc.org/CERT-C/MEM35-C
        see CERT-C section STR31-C http://rvdoc.org/CERT-C/STR31-C
        see MISRA-C section 8.1:3 http://rvdoc.org/MISRA-C/8.1

Found pointer that refers outside the bounds of an object + 1:
      > in fgets at simple-bof.c:17:9
        in main at simple-bof.c:17:9

    Undefined behavior (UB-CEE3):
        see C11 section 6.3.2.1:1 http://rvdoc.org/C11/6.3.2.1
        see C11 section J.2:1 item 19 http://rvdoc.org/C11/J.2
        see CERT-C section ARR30-C http://rvdoc.org/CERT-C/ARR30-C
        see CERT-C section ARR37-C http://rvdoc.org/CERT-C/ARR37-C
        see CERT-C section STR31-C http://rvdoc.org/CERT-C/STR31-C
        see MISRA-C section 8.1:3 http://rvdoc.org/MISRA-C/8.1

Reading outside the bounds of an object:
      > in fgets at simple-bof.c:17:9
        in main at simple-bof.c:17:9

    Undefined behavior (UB-EIO7):
        see C11 section 6.3.2.1:1 http://rvdoc.org/C11/6.3.2.1
        see C11 section J.2:1 item 19 http://rvdoc.org/C11/J.2
        see CERT-C section ARR30-C http://rvdoc.org/CERT-C/ARR30-C
        see CERT-C section ARR37-C http://rvdoc.org/CERT-C/ARR37-C
        see CERT-C section STR31-C http://rvdoc.org/CERT-C/STR31-C
        see CERT-C section STR32-C http://rvdoc.org/CERT-C/STR32-C
        see MISRA-C section 8.1:3 http://rvdoc.org/MISRA-C/8.1

Indeterminate value used in an expression:
      > in fgets at simple-bof.c:17:9
        in main at simple-bof.c:17:9

    Undefined behavior (UB-CEE2):
        see C11 section 6.2.4 http://rvdoc.org/C11/6.2.4
        see C11 section 6.7.9 http://rvdoc.org/C11/6.7.9
        see C11 section 6.8 http://rvdoc.org/C11/6.8
        see C11 section J.2:1 item 11 http://rvdoc.org/C11/J.2
        see CERT-C section EXP33-C http://rvdoc.org/CERT-C/EXP33-C
        see MISRA-C section 8.9:1 http://rvdoc.org/MISRA-C/8.9
        see MISRA-C section 8.1:3 http://rvdoc.org/MISRA-C/8.1

Reading outside the bounds of an object:
      > in puts at simple-bof.c:18:9
        in main at simple-bof.c:18:9

    Undefined behavior (UB-EIO7):
        see C11 section 6.3.2.1:1 http://rvdoc.org/C11/6.3.2.1
        see C11 section J.2:1 item 19 http://rvdoc.org/C11/J.2
        see CERT-C section ARR30-C http://rvdoc.org/CERT-C/ARR30-C
        see CERT-C section ARR37-C http://rvdoc.org/CERT-C/ARR37-C
        see CERT-C section STR31-C http://rvdoc.org/CERT-C/STR31-C
        see CERT-C section STR32-C http://rvdoc.org/CERT-C/STR32-C
        see MISRA-C section 8.1:3 http://rvdoc.org/MISRA-C/8.1

Indeterminate value used in an expression:
      > in puts at simple-bof.c:18:9
        in main at simple-bof.c:18:9

    Undefined behavior (UB-CEE2):
        see C11 section 6.2.4 http://rvdoc.org/C11/6.2.4
        see C11 section 6.7.9 http://rvdoc.org/C11/6.7.9
        see C11 section 6.8 http://rvdoc.org/C11/6.8
        see C11 section J.2:1 item 11 http://rvdoc.org/C11/J.2
        see CERT-C section EXP33-C http://rvdoc.org/CERT-C/EXP33-C
        see MISRA-C section 8.9:1 http://rvdoc.org/MISRA-C/8.9
        see MISRA-C section 8.1:3 http://rvdoc.org/MISRA-C/8.1

66666666
```