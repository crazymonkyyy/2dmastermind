import raylib;
import std;
//logic
enum colors=5;
ubyte[4][4] table;
bool[4][4] playerknowlegde;
alias path=ubyte*[4];
enum numpath=10;
path[numpath] paths;
void initpaths(){
	paths[0]=[&table[0][0],&table[0][1],&table[0][2],&table[0][3]];
	paths[1]=[&table[1][0],&table[1][1],&table[1][2],&table[1][3]];
	paths[2]=[&table[2][0],&table[2][1],&table[2][2],&table[2][3]];
	paths[3]=[&table[3][0],&table[3][1],&table[3][2],&table[3][3]];
	paths[4]=[&table[0][0],&table[1][0],&table[2][0],&table[3][0]];
	paths[5]=[&table[0][1],&table[1][1],&table[2][1],&table[3][1]];
	paths[6]=[&table[0][2],&table[1][2],&table[2][2],&table[3][2]];
	paths[7]=[&table[0][3],&table[1][3],&table[2][3],&table[3][3]];
	paths[8]=[&table[0][0],&table[1][1],&table[2][2],&table[3][3]];
	paths[8]=[&table[0][3],&table[1][2],&table[2][1],&table[3][0]];
}

alias responce=byte[4];
enum geusses=10;
responce[numpath][geusses] geusstable=-1;
byte[numpath] geussoffset;

//ui
ubyte activepath;
auto activepath_() => paths[activepath];

int score;
byte[4] geuss;

//layout bullshit
enum windowx=920;//taken from sandtrix on my rotated monitor
enum windowy=500;


// logic functions
void filltable(){
	foreach(ref list;table){
	foreach(ref e; list){
		e=uniform(0,colors).to!ubyte;
	}}
	foreach(ref list;playerknowlegde){
	foreach(ref e;list){
		e=false;
	}}
}
responce mastermindlogic(path truth_, byte[4] geuss){
	responce o;
	int i;
	auto truth=truth_[].map!(a=>*a).array;
	foreach(j;0..4){
		if(truth[j]==geuss[j]){
			truth[j]=cast(ubyte)-1;
			geuss[j]=-2;
			o[i]=6; i++;
	}}
	foreach(a;geuss){
		auto j=truth[].countUntil(a);
		if(j!=-1){
			truth[j]=cast(ubyte)-1;
			o[i]=2;
			i++;
		}
	}
	return o;
}
void revealrandom(){
	loop:
	int x=uniform(0,4);
	int y=uniform(0,4);
	if(playerknowlegde[x][y]==true){
		goto loop;
	}
	playerknowlegde[x][y]=true;
}
void resetgeuss(){geuss=[-1,-1,-1,-1];}
void typegeuss(byte a){
	auto i=geuss[].countUntil(byte(-1));
	if(i!=-1){
		geuss[i]=a;
	}
}
void makegeuss(){
	if(mastermindlogic(activepath_,geuss)==[6,6,6,6]){markcorrect(activepath_);}
	geusstable[activepath][geussoffset[activepath]]=geuss;
	resetgeuss;
	geussoffset[activepath]++;
	
}
void markcorrect(path p){
	foreach(_a;p){
		ulong a=cast(ulong)_a;
		a-=cast(ulong)&table;
		a+=cast(ulong)&playerknowlegde;
		bool* b=cast(bool*)a;
		*b=true;
}}
void cycleactive(){
	activepath++;
	activepath%=numpath;
}

// draw functions
Color[] colors_ = [
    Color(0x00, 0x2B, 0x36, 0xFF),
    Color(0x07, 0x36, 0x42, 0xFF),
    Color(0x58, 0x6E, 0x75, 0xFF),
    Color(0x65, 0x7B, 0x83, 0xFF),
    Color(0x83, 0x94, 0x96, 0xFF),
    Color(0x93, 0xA1, 0xA1, 0xFF),
    Color(0xEE, 0xE8, 0xD5, 0xFF),
    Color(0xFD, 0xF6, 0xE3, 0xFF),
    Color(0xDC, 0x32, 0x2F, 0xFF),
    Color(0xCB, 0x4B, 0x16, 0xFF),
    Color(0xB5, 0x89, 0x00, 0xFF),
    Color(0x85, 0x99, 0x00, 0xFF),
    Color(0x2A, 0xA1, 0x98, 0xFF),
    Color(0x26, 0x8B, 0xD2, 0xFF),
    Color(0x6C, 0x71, 0xC4, 0xFF),
    Color(0xD3, 0x36, 0x82, 0xFF)
  ];
void drawtable(){
	foreach(x;0..4){
	foreach(y;0..4){
		DrawCircle(x*50+25,y*50+25,20,
		playerknowlegde[x][y]?
			colors_[8+table[x][y]]:
			Colors.GRAY
		);
	}}
}
void drawgeuss(){
	foreach(x;0..4){
		DrawCircle(x*50+25,50*6,20,
			geuss[x]==-1?
				Colors.GRAY:
				colors_[8+geuss[x]]
		);
	}
}
void drawactiveline(){
	DrawText(activepath.to!string.toStringz,300,0,20,Colors.WHITE);
}
void drawoldgeusses(){
	foreach(int y,res;geusstable[activepath]){
		foreach(x;0..4){
			DrawCircle(x*30+300,y*30+30,15,
				res[x]==-1?
					Colors.GRAY:
					colors_[8+res[x]]
			);
		}
		mastermindlogic(activepath_,res)
			.to!string.toStringz
			.DrawText(450,y*30+30,15,Colors.WHITE);
	}
}
void main(){
	InitWindow(windowx, windowy, "Hello, Raylib-D!");
	SetWindowPosition(1800,300);
	SetTargetFPS(60);
	initpaths;
	filltable;
	table.writeln;
	resetgeuss;
	while (!WindowShouldClose()){
		BeginDrawing();
			ClearBackground(Colors.BLACK);
			drawtable;
			drawgeuss;
			drawactiveline;
			drawoldgeusses;
			import monkyyykeys;
			with(button){
			foreach(byte i;0..colors){
				if((_1+i).pressed){typegeuss(i);i.writeln;}
			}
			if(enter.pressed){makegeuss;"enter".writeln;}
			if(backspace){resetgeuss;}
			if(tab.pressed){cycleactive;}
			}
		EndDrawing();
	}
	CloseWindow();
}