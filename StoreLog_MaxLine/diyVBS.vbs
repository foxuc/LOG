' Change the code of a file.
' By Eric Brown
' 用法为：
'cscript chcode.vbs inputfile.txt
'会把inputfile.txt转换为utf-8格式编码
'cscript chcode.vbs inputfile.txt outputfile.txt -o ansi
'会把inputfile.txt转成为ansi编码的outputfil.txt，原文件不变。


'Get the arguments
Set argv = WScript.Arguments

if argv.Length = 0 Then
    Call PrintHelp
end if

'The default code
inCode = ""
outCode = "utf-8"

haveOut = False
haveInCode = False
getInput = False
inFile = ""
outFile = ""
'If force, will replace the output
'without asking.
force = False

'Analyse the arguments
For i = 0 to argv.Length - 1
    isOption = False
    if StrComp(argv(i), "-i", vbTextCompare) = 0 Then
        i = i + 1
        inCode = argv(i)
        haveInCode = True
        isOption = True
    elseif StrComp(argv(i), "-o", vbTextCompare) = 0 Then
        i = i + 1
        outCode = argv(i)
        isOption = True
    elseif StrComp(argv(i), "-f", vbTextCompare) = 0 Then
        force = True
        isOption = True
    elseif StrComp(argv(i), "-h", vbTextCompare) = 0 Then
        Call PrintHelp
    end if

    if not isOption then
        if not getInput Then
            inFile = argv(i)
            getInput = True
        else
            outFile = argv(i)
            haveOut = True
        end if
    end if
Next

if not haveOut then
    outFile = inFile
end if

'If output isn't specified
'Make a temp file
if not haveOut then
    outFile = outFile & "~~~~~~~"
end if
'Is the output format supported?
if StrComp(LCase(outCode), "utf-8") <> 0 and _
   StrComp(LCase(outCode), "gb2312") <> 0 and _
   StrComp(LCase(outCode), "unicode") <> 0 then
    if StrComp(LCase(outCode), "ansi") then
        outCode = "gb2312"
    else
        WScript.echo "Unsupported format: " & outCode
        WScript.Quit
    end if
end if
if StrComp(LCase(inCode), "ansi") = 0 then
    inCode = "gb2312"
end if

Call CheckCode(inFile)

'If the output is already existed
'Check it unless -f is specified
Set fso = CreateObject("Scripting.FileSystemObject")
if fso.FileExists(outFile) and not force then
    choice = Msgbox(outFile & " has been existed!" & vbCrlf & _
            " Do you want to replace it?", vbQuestion + vbYesNo, _
            "Output file has been existed")
    if choice = vbNo Then
        WScript.Quit
    end if
end if

Set instream = CreateObject("Adodb.Stream")
Set outstream = CreateObject("Adodb.Stream")

'Open input file
instream.Type = 2 'adTypeText
instream.Mode = 3 'adModeReadWrite
instream.Charset = inCode
instream.Open
instream.LoadFromFile inFile

'Read input file
content = instream.ReadText

'Close input file
instream.Close
Set instream = Nothing

'Open output file
outstream.Type = 2 'adTypeText
outstream.Mode = 3 'adModeReadWrite
outstream.Charset = outCode
outstream.Open

'Write to output file
outstream.WriteText content
outstream.SaveToFile outFile, 2 'adSaveCreateOverWrite
outstream.flush

'Close output file
outstream.Close
Set outstream = Nothing

'If not specify the output file
'then replace the input file
if not haveOut then
    set srcFile = fso.getFile(inFile)
    srcFile.delete
    set srcFile = fso.getFile(outFile)
    srcFile.name = inFile
end if


Function CheckCode(Sourcefile)
    'WScript.echo "Checking: " & Sourcefile
    Dim stream
    set stream = CreateObject("Adodb.Stream")
    stream.Type = 1 'adTypeBinary
    stream.Mode = 3 'adModeReadWrite
    stream.Open
    stream.Position = 0
    stream.LoadFromFile Sourcefile
    Bin = stream.read(2)
    if AscB(MidB(Bin, 1, 1)) = &HEF and _
        AscB(MidB(Bin, 2, 1)) = &HBB Then
        Codes = "utf-8"
    elseif AscB(MidB(Bin, 1, 1)) = &HFF and _
        AscB(MidB(Bin, 2, 1)) = &HFE Then
        Codes = "unicode"
    else
        Codes = "gb2312"
    end if

    if not haveInCode Then
        inCode = Codes
    end if
    if StrComp(LCase(inCode), Codes) <> 0 then
        WScript.echo "Detected input format is: " & Codes &_
            vbCrlf & "But you specified " & inCode & "."
        WScript.Quit
    end if
    stream.Close
    set stream = Nothing
end Function

Function PrintHelp()
    message = "Usage: cscript chcode.vbs inFileName (outFileName) " & _
                "(Options)" & vbCrlf & _
                "If the outFileName is not specified, this program " & _
                "will change the inFileName's code" & vbCrlf & _
                "OPTIONS" & vbCrlf & _
                "    -i [inCode]: Specify the code " & _
                "of input file."& vbCrlf &_
                "                 If not specified, program will " & _
                "auto detect the code of the input file." & vbCrlf & _
                "    -o [outCode]: Specify the code of output file." & _
                vbCrlf & "                  The default is utf-8" & _
                vbCrlf & _
                "    -f: If the output file is specified, don't ask." & _
                vbCrlf & "SUPPORTED FORMAT" & vbCrlf & _
                "      utf-8" & vbCrlf & _
                "      ansi or gb2312" & vbCrlf & _
                "      unicode" & vbCrlf
    WScript.echo message
    WScript.Quit
end Function