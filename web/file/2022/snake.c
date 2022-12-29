//头文件
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h> //微秒us
//移动光标位置
#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__)
#include <windows.h>
void SetCursorPos(int XPos, int YPos)
{
 COORD Coord;

 Coord.X = XPos;
 Coord.Y = YPos;

 SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), Coord);
}
#else
void SetCursorPos(int XPos, int YPos)
{
 printf("\033[%d;%dH", YPos+1, XPos+1);
}
#endif

// 隐藏光标
#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__)
    #include <windows.h>
    void hidecursor()
    {
     HANDLE consoleHandle = GetStdHandle(STD_OUTPUT_HANDLE);
     CONSOLE_CURSOR_INFO info;
     info.dwSize = 100;
     info.bVisible = FALSE;
     SetConsoleCursorInfo(consoleHandle, &info);
    }
#else
    void hidecursor()
    {
     printf("\e[?25l");
    }
#endif

//从键盘读入
#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__)
#else
#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>

int kbhit(void)
{
  struct termios oldt, newt;
  int ch;
  int oldf;

  tcgetattr(STDIN_FILENO, &oldt);
  newt = oldt;
  newt.c_lflag &= ~(ICANON | ECHO);
  tcsetattr(STDIN_FILENO, TCSANOW, &newt);
  oldf = fcntl(STDIN_FILENO, F_GETFL, 0);
  fcntl(STDIN_FILENO, F_SETFL, oldf | O_NONBLOCK);

  ch = getchar();

  tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
  fcntl(STDIN_FILENO, F_SETFL, oldf);

  if(ch != EOF)
  {
    ungetc(ch, stdin);
    return 1;
  }

  return 0;
}

#define _kbhit kbhit
#define _getch getchar

#endif



//流程
/*
- 生成地图
- 生成蛇、障碍物
- 画蛇
- 随机食物
- 移动蛇
>> 读入键盘方向
>> 判断、死亡、食物、正常
>>>> (X,Y)=P[0]->(x,y)+(dx,dy); 新蛇头位置并申请空间
>>>>>>>> 判断新蛇头死亡,可以适度返回修改dxdy
>>>>>>>> 判断新蛇头食物, 蛇身体长度+1: n=n+1
>>>>>>>> 判断正常
>> 光标生成蛇头,旧头变身体,(P[n] != NULL 吃到食物时为NULL)清除身体
>> P[i]=P[i-1] i=1,n ;蛇身体
>> P[0]=&((X,Y));新蛇头的坐标
*/

typedef struct {
    int X;
    int Y;
} _coor;

typedef struct{
    int height;
    int width;
} _map;

typedef struct{
    int X;
    int Y;
} _food;


typedef struct {
    _coor **list;
    int length; // 蛇长度
    _food *food;
    _map *map;
}_snake;

//画字符
void plotchar(int X, int Y, char c){
    //printf("%d,%d,%c\n",X,Y,c);return;
    SetCursorPos(X,Y); //从0开始
    printf("%c",c);
    fflush(stdout);
    hidecursor();
    return;
}

//读入地图尺寸
void init_map(_map *map){
    map->height=10;
    map->width=20;
};
//分数
void score(_snake * snake){
    plotchar(snake->map->width,snake->map->height-1,'\n');
    printf("Score: %d\n",snake->length-2);
    return;
}

//定期重新刷新界面
void flashui(_snake *snake){
    //
    //清空画布
#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__)
    system("cls");
#else
    system("clear");
#endif    
    for ( int i=0; i< snake->map->height; i++){
        printf("#");
        for ( int j=1; j< snake->map->width-1; j++){
            if ( i == 0 || i == snake->map->height-1 ){
                printf("#");
            }
            else{
                printf(" ");
            }
        }
        printf("#\n");
    }
    //处理一下地图
    plotchar(0,1,'|');
    plotchar(1,0,'-');
    //
    //刷新蛇
    plotchar(snake->list[0]->X,snake->list[0]->Y,'@');
    for ( int i =1 ; i < snake -> length ; i++){
        plotchar(snake->list[i]->X,snake->list[i]->Y,'*');
    }
    //刷新食物
    plotchar(snake->food->X,snake->food->Y,'O');
    //刷新分数
    score(snake);
    return;
}


// 初始化所有
void init(_snake *snake){
    //
    //
    //画地图,原则上只用画一次
    snake->map=(_map *) malloc(sizeof(_map));
    init_map(snake->map);

    //食物
    snake->food=(_food *) malloc(sizeof(_food));
    memset( snake->food,0,sizeof(snake->food));

    //身体指针,随着占用的空间,逐渐申请身体空间
    //申请全空间是防止撞到蛇
    int space =(snake->map->height-2)*(snake->map->width-2);
    snake->list= ( _coor ** ) malloc(sizeof(_coor *)*space); // ~指针数组
    memset( snake->list, 0, sizeof(_coor *)*space); //写入0,就是把地址变成了NULL, 由于NULL是void *, 这里不能把int 0 换成NULL刷入
    //
    //首次画蛇
    snake->length=2;
    snake->list[0]=(_coor *) malloc(sizeof(_coor));
    snake->list[1]=(_coor *) malloc(sizeof(_coor));
    snake->list[0]->X=snake->map->width/2;
    snake->list[0]->Y=snake->map->height/2;
    snake->list[1]->X=snake->list[0]->X+1;
    snake->list[1]->Y=snake->list[0]->Y;
    plotchar(snake->list[0]->X,snake->list[0]->Y,'@');
    plotchar(snake->list[1]->X,snake->list[1]->Y,'*');
    //初次刷新
    flashui(snake);
    return;
}

void end(_snake *snake){
    //
    score(snake);
    //
    free(snake->food);
    free(snake->map);
    for ( int i = 0; i< snake->length; i++) free(snake->list[i]);
    free(snake->list);
    free(snake);
}

// 随机食物位置
void newfood(_snake *snake){
    static int initrand=1;
    if ( initrand ){
        srand((unsigned)time( NULL ) ); //设置随机数种子
        initrand = 0;
    }

    snake->food->X=rand()%(snake->map->width-2)+1; //随机数在1~n-2
    snake->food->Y=rand()%(snake->map->height-2)+1; //随机数在1~n-2
    //
    for ( int i=0; i < snake->length; i++){
        if ( snake->food->X == snake->list[i]->X)
        {
            if ( snake->food->Y == snake->list[i]->Y){
                newfood(snake);
                return;
            }
        }

    }
    plotchar(snake->food->X,snake->food->Y,'O');
    return;
}

int checksnake(_snake *snake, int dx, int dy){
    int X=snake->list[0]->X+dx;
    int Y=snake->list[0]->Y+dy;
    if ( X <= 0 || Y <= 0 || X >= snake->map->width-1 || Y >= snake->map->height-1){
        return -1;
    }
    else if ( X == snake->food->X && Y == snake->food->Y )
    {
        return 1;
    }
    else{
        //检查是否撞到蛇
        for ( int i = 1; i < snake->length-1; i++){
            if ( X == snake->list[i]->X && Y == snake->list[i]->Y) return -1;
        }
    }
    return 0;
}

void key(char * direct){
    int i=rand()%4;
    if (i == 0) *direct='w';
    if (i == 1) *direct='a';
    if (i == 2) *direct='s';
    if (i == 3) *direct='d';
    return;
}
void move(_snake *snake){
    static double waittime=1.0*1e6; //录入间隔,[us]
    static int step=0;
    time_t start_t,finish_t; // 时间
    waittime=waittime*0.999; // 反应时间越来越短
    if (step == 0 ) newfood(snake);
    step++;
    //
    //获得移动方向
    time(&start_t);
    time(&finish_t); //这个只能获得s单位,就先以s为单位
    char direct=0;
    int N=10; // 检测键盘间隔 waittime/N
    for ( int i = 1; i < N ; i++)
    {
        if( _kbhit() ){
            direct=_getch();
            plotchar(0,0,direct);
            flashui(snake); //有键盘输入就刷新一下页面
            break; //无论有效无效均抛出
        }
        usleep( (int) waittime/N ); 
    }
    int dx=0,dy=0;
    static int goldkey=0;
RESTART:
    switch(direct)
    {
        //由于我们认为的屏幕上,是计算机的下,刚好反过来
        case 'w':
        case 'W':
            dx=0;dy=-1;
            break; 
        case 'a':
        case 'A':
            dx=-1;dy=0;
            break; 
        case 's':
        case 'S':
            dx=0;dy=1;
            break; 
        case 'd':
        case 'D':
            dx=1;dy=0;
            break;
        case '/': //金手指
            goldkey=(goldkey+1)%2;
            break;
    };
    //printf("direct=%c(%d),dx=%d,dy=%d;",direct,step,dx,dy);
    if ( dx+dy == 0 || \
        ( dx == snake->list[1]->X-snake->list[0]->X && \
          dy == snake->list[1]->Y-snake->list[0]->Y ))
    {
            dx=snake->list[0]->X-snake->list[1]->X;
            dy=snake->list[0]->Y-snake->list[1]->Y;
    }
    //判断下一时刻位置,
    int state=checksnake(snake,dx,dy);
    //
    //金手指
    if ( goldkey ){ 
        // 鬼打墙随机一下
        static  int state_1=0; // 持续失败次数,多了就说明over了
        static  int state0=0; // 持续无操作次数,多了说明边界转圈了

        //修正错误操作
        if ( state < 0 ){
            if ( ++state_1 < (snake->map->height+snake->map->width)*2){
                //重新找
                key(&direct);
                goto RESTART;  
            }
        }
        else{
            state_1=0;
        }
        //随机行走
        if ( state == 0 ){
            if ( ++state0 > (snake->map->height+snake->map->width)*2){
                key(&direct);
                state0=(int) state0*0.95;
                goto RESTART;
            }
        }
        else{
            state0=0;
        }

    }
    //
    //
    if ( state < 0 ) return;
    if ( state > 0 ) snake->list[snake->length++]=(_coor *) malloc(sizeof(_coor)); //增加新空间
    int length=snake->length;
    //正常情况,移动后,清除蛇尾;而吃了分数的旧尾部的位置不用变不存在,不用清楚
    //要在这里清和添加, 后面就要改数据了
    if ( state == 0) plotchar(snake->list[length-1]->X,snake->list[length-1]->Y,' ');
    // 循环改指蛇身的指向的空间
    // 备份蛇尾给蛇头
    _coor * head=snake->list[length-1];
    //移动蛇身
    memmove((void *) ( snake->list+1) , (void *) snake->list, sizeof(_coor **) *(length-1) );
    //恢复蛇头
    snake->list[0]=head;
    snake->list[0]->X=snake->list[1]->X+dx;
    snake->list[0]->Y=snake->list[1]->Y+dy;

    //打印新蛇头,覆盖旧蛇头,吃到分数后会自动覆盖分数,不用额外清楚
    plotchar(snake->list[1]->X,snake->list[1]->Y,'*');
    plotchar(snake->list[0]->X,snake->list[0]->Y,'@');
    //
    //更新分数,结束循环
    score(snake);
    if(state > 0) newfood(snake);
    move(snake);
}
int main(){
    _snake *snake=(_snake *) malloc(sizeof(_snake));
    system("clear");
    init(snake);
    move(snake);
    end(snake);
    //system("sleep 10");
    return 0;
}