package main

import (
	"fmt"
	"time"
	"strings"
	"os"
	"bufio"
	"io"
	"github.com/axgle/mahonia"
	"path/filepath"
	"github.com/nsf/termbox-go"
	"strconv"
)

var p = fmt.Println
//初始化pause
func init() {
	if err := termbox.Init(); err != nil {
		panic(err)
	}
	termbox.SetCursor(0, 0)
	termbox.HideCursor()
}

func main() {
	NowTime :=time.Now().Format("2006_01_02_15_04_05")
	p("Ver:","FishStoreLog MaxLine by hi-2018-09-14 ver:0.001")
	p("NowTime:",NowTime)
	p("NowPath:",getCurrentDirectory())
	inipath :=filepath.Join( getCurrentDirectory(),"FishStoreLog.ini")
	p("inipath:",inipath)
	iniArr :=ReadFileToArr(inipath)
	for key, value := range iniArr {
		inipath :=filepath.Join( getCurrentDirectory(),value)
		fmt.Println(key, ":", inipath)
		if IsDirFileExist(inipath) {
		LastString :=ReadFileToLastLine(string(inipath))
		p(LastString)
		p("\n")
		}

	}
	pause()
}

func ConvertToString(src string, srcCode string, tagCode string) string {
	srcCoder := mahonia.NewDecoder(srcCode)
	srcResult := srcCoder.ConvertString(src)
	tagCoder := mahonia.NewDecoder(tagCode)
	_, cdata, _ := tagCoder.Translate([]byte(srcResult), true)
	result := string(cdata)
	return result
}

func pause() {
	fmt.Println("hi.请按任意键继续...")
Loop:
	for {
		switch ev := termbox.PollEvent(); ev.Type {
		case termbox.EventKey:
			break Loop
		}
	}
}

func ReadFileToArr(fileName string) ([]string)  {
	f, err := os.Open(fileName)
	if err != nil {
		//return err
	}
	buf := bufio.NewReader(f)
	arr :=[]string{};
	for {
		line, err := buf.ReadString('\n')
		line = strings.TrimSpace(line)
		//handler(line)
		if line !="" {
			arr = append(arr,line);
		}

		if err != nil {
			if err == io.EOF {
				return arr
			}
			//return err
		}
	}
	return arr
}

func ReadFileToLastLine(fileName string) (string)  {

	if !IsDirFileExist(fileName) {
		p( fileName,":IsDirFileExist:",)
		return ""
	}

	f, _ := os.Open(fileName)
	 buf := bufio.NewReader(f)

	arr :=  []string{}
	len1 :=0;
	LastLine :="";
	for {
		line, err := buf.ReadString('\n')
		line = strings.TrimSpace(line)

		if line !=""  {
			arr = append(arr,line);
			len1 =len(arr);
		}
		if err != nil {
			if err == io.EOF {
				LastLine ="【MaxLine:"+ strconv.Itoa (len1-1)+ "】," + string(arr[len1-1])
				return LastLine
			}
		}
	}
	return LastLine
}

func checkFileIsExist(filename string) bool {
	var exist = true
	if _, err := os.Stat(filename); os.IsNotExist(err) {
		exist = false
	}
	return exist
}


//判断文件或文件夹是否存在
func IsDirFileExist(fp string) bool {
	_, err := os.Stat(fp)
	return err == nil || os.IsExist(err)
}

/*获取程序运行路径*/
func getCurrentDirectory() string {
	dir, err := filepath.Abs(filepath.Dir(os.Args[0]))
	if err != nil {
		p(err)
	}
	return strings.Replace(dir, "\\", "/", -1)
}
