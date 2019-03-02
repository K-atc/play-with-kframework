Play with K Framework
====

K Framework  
http://www.kframework.org/


Requirements
----
* `kcc` ... [kcc](https://runtimeverification.com/match/download/) must be located at `$PATH`
    * I recommend *runtime verification*'s rv-match 
* `afl-fuzz` ... Build AFL beforehand. I assume `afl-fuzz` is located at `~/bin/afl-2.52b/`


How to build
----
```shell
cd vuln-samples
make
```


Let's play!
----
### Step 0) About demo `simple-bof`
[simple-bof.c](simple-bof.c) contains buffer overflow bug. Let's see how we triage crash reported by AFL, using K Framework.

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
```shell
rm -rf afl-output/simple-bof
~/bin/afl-2.52b/afl-fuzz -i fuzz/simple-bof/ -o afl-output/simple-bof ./simple-bof.afl
```

### Step 3) Verify crash input with K Framework (c-semantics)
```shell
cat SOME_CRASH_INPUT | ./simple-bof.kcc
```

For example:

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