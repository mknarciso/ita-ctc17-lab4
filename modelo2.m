clear all
clc

camargos=load('Rio 01 Camargos.txt');
furnas=load('Rio 02 Furnas.txt');

P1camargos=[];
P2camargos=[];
Tcamargos=[];
P1furnas=[];
P2furnas=[];
Tfurnas=[];

for i=1:1:82
    P1camargos = [P1camargos camargos(i,:)];
    P1furnas = [P1furnas furnas(i,:)];
end
for i=2:1:983
    P2camargos = [P2camargos camargos(i-1)];
    Tcamargos = [Tcamargos camargos(i+1)];
    P2furnas = [P2furnas furnas(i-1)];
    Tfurnas = [Tfurnas furnas(i+1)];
end
P1camargos = P1camargos(2:983)
P1furnas = P1furnas(2:983)

P = [P1camargos; P2camargos; P1furnas; P2furnas];
T = [Tcamargos; Tfurnas];

net = feedforwardnet([20 30 25]);
net = configure(net,P,T);

net.divideFcn='divideblock';
net.divideParam.trainRatio=0.80;
net.divideParam.valRatio=0.10;
net.divideParam.testRatio=0.10;

net=init(net);

net.trainParam.showWindow=true;
net.layers{1}.dimensions=20;
net.layers{1}.transferFcn='tansig';
net.layers{2}.dimensions=30;
net.layers{2}.transferFcn='tansig';
net.layers{3}.dimensions=25;
net.layers{3}.transferFcn='tansig';
net.layers{4}.transferFcn='purelin';
net.performFcn='mse';
%net.trainFcn='trainbr';
%net.trainFcn='trainrp';
net.trainFcn='trainlm';
net.trainParam.epochs=1000;
net.trainParam.time=120;
net.trainParam.lr=0.1;
net.trainParam.min_grad=10^-18;
net.trainParam.max_fail=1000;
[net, tr]=train(net,P,T);

xP=1:1:(82*12-2);
plot(xP,P1camargos,'b',xP,P1furnas,'r')
xlabel('Meses')
ylabel('Vazao')
title('Vazao dos rios')
grid

hold on
xS=xP(1:981);
PsA=P(:,1);
Ms=PsA;
for i=1:1:982
    PsD=sim(net,PsA);
    PsD=[PsD(1);PsA(1);PsD(2);PsA(2)];
    Ms=[Ms PsD];
    PsA=PsD;
end
y1S=[];
y2S=[];
for i=2:1:982
    y1S=[y1S Ms(1,i-1) ];
    y2S=[y2S Ms(3,i-1) ];
end
plot(xS,y1S,':b');
plot(xS,y2S,':r');


