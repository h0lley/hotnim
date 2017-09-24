# Reproduction steps

1. Get your nimrtl lib: https://nim-lang.org/docs/nimc.html#dll-generation
2. Compile the main binary: `nim -d:useNimRtl c main`
3. Compile the lib that contains the code that can be reloaded on runtime: `nim --app:lib -d:useNimRtl c lib`
4. Run `./main` - something like this should now pop up in the console every two seconds:
```
version 1
sequence reallocation worked
```
5. Open the lib.nim in your code editor and change the echo in line 12 to print something different (e.g. "version 2")
6. Open another terminal and do `nim --app:lib -d:useNimRtl c lib` once again
7. Now in the terminal that runs the main binary, you can confirm that hot loading works by comparing the output:
```
version 2
sequence reallocation worked
```
8. Go back to the code editor, change the string to "version 3" and comment the dummy code out
9. Recompile the lib
10. Check the terminal that runs the main binary. Here's what I get:
```
version 3
No stack traceback available
SIGSEGV: Illegal storage access. (Attempt to read from nil?)
```
