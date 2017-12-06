clear all
clc

camargos=load('Rio 01 Camargos.txt');
furnas=load('Rio 02 Furnas.txt');

P1camargos=[];
P2camargos=[];
P3camargos=[];
Tcamargos=[];
P1furnas=[];
P2furnas=[];
P3furnas=[];
Tfurnas=[];

for i=1:1:82
    P1camargos = [P1camargos camargos(i,:)];
    P1furnas = [P1furnas furnas(i,:)];
end
for i=3:1:983
    P2camargos = [P2camargos camargos(i-1)];
    P3camargos = [P3camargos camargos(i-2)];
    Tcamargos = [Tcamargos camargos(i+1)];
    P2furnas = [P2furnas furnas(i-1)];
    P3furnas = [P3furnas furnas(i-2)];
    Tfurnas = [Tfurnas furnas(i+1)];
end
P1camargos = P1camargos(3:983)
P1furnas = P1furnas(3:983)

P = [P1camargos; P2camargos; P3camargos; P1furnas; P2furnas; P3furnas];
T = [Tcamargos; Tfurnas];

net = feedforwardnet(20);
net = configure(net,P,T);

net.divideFcn='divideblock';
net.divideParam.trainRatio=0.80;
net.divideParam.valRatio=0.10;
net.divideParam.testRatio=0.10;

net=init(net);

net.trainParam.showWindow=true;
net.layers{1}.dimensions=20;
net.layers{1}.transferFcn='tansig';
net.layers{2}.transferFcn='purelin';
net.performFcn='mse';
%net.trainFcn='trainbr';
%net.trainFcn='trainrp';
net.trainFcn='trainlm';
net.trainParam.epochs=1000;
net.trainParam.time=240;
net.trainParam.lr=0.2;
net.trainParam.min_grad=10^-18;
net.trainParam.max_fail=1000;
[net, tr]=train(net,P,T);

xP=1:1:(82*12-3);
plot(xP,P1camargos,'b',xP,P1furnas,'r')
xlabel('Meses')
ylabel('Vazao')
title('Vazao dos rios')
grid

hold on
xS=xP(1:981);
PsA=P(:,1);
Ms=PsA;
for i=1:1:981
    PsD=sim(net,PsA);
    PsD=[PsD(1);P2camargos(i);P3camargos(i);PsD(2);P2furnas(i);P3furnas(i)];
    Ms=[Ms PsD];
    PsA=PsD;
end
y1S=[];
y2S=[];
for i=2:1:982
    y1S=[y1S Ms(1,i-1) ];
    y2S=[y2S Ms(4,i-1) ];
end
plot(xS,y1S,':b');
plot(xS,y2S,':r');


