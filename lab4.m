clear all
clc

camargos=load('Rio 01 Camargos.txt');

Pcamargos=[];
Tcamargos=[];

for i=1:1:40
    Pcamargos = [Pcamargos camargos(i,:)'];
    Tcamargos = [Tcamargos camargos(i+1,:)'];
end
P = [Pcamargos];
T = [Tcamargos];

net = feedforwardnet(20);
net = configure(net,P,T);

net.divideFcn='dividerand';
net.divideParam.trainRatio=1.00;
net.divideParam.valRatio=0.00;
net.divideParam.testRatio=0.00;

net=init(net);

net.trainParam.showWindow=true;
net.layers{1}.dimensions=20;
net.layers{1}.transferFcn='tansig';
net.layers{2}.transferFcn='purelin';
net.performFcn='mse';
%net.trainFcn='trainbr';
%net.trainFcn='trainrp';
net.trainFcn='trainlm';
net.trainParam.epochs=1000000;
net.trainParam.time=240;
net.trainParam.lr=0.2;
net.trainParam.min_grad=10^-18;
net.trainParam.max_fail=1000;
[net, tr]=train(net,P,T);

xP=1:1:(41*12);
xF=(41*12)+1:1:42*12;
XcamargosP=[];
for i=1:1:41
    XcamargosP=[XcamargosP camargos(i,:)];
end
XcamargosF=camargos(42,:);
plot(xP,XcamargosP,'b',xF,XcamargosF,'r')
xlabel('Meses')
ylabel('Vazao')
title('Vazao do Rio Camargos')
grid

hold on
xS=1:1:(42*12);
PsA=camargos(1,:)';
Ms=PsA;
for i=1:1:41
    PsD=sim(net,PsA);
    Ms=[Ms PsD];
    PsA=PsD;
end
yS=[];
for i=1:1:42
    yS=[yS Ms(:,i)'];
end
plot(xS,yS,':m');


