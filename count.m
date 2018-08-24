shed_bg = 0.06;%0.034
SplitShed = 0.001;
SplitShed_denoise = 0.019;
cir_precision = 0.974;
precision_flag = true;
RadiiRatio = 0.2;
WaveletCheck = true;
flag = false;
ImproveMode = false;
MultiCam = true;
CircleInterRatio = 0.1;%0.22
rgb = false;
WebTransfer = true;
presentation = false;
Morecircles = true;
MorecirclesNum = 0.009;
WhetherCut = false;

dirc=[0 1;1 0;0 -1;-1 0];
m=480;
n=640;
for i=1:m
 for j=1:n
  White(i,j,:)=[0;0;0];
 end
end

vid1=videoinput('winvideo',1,'MJPG_640x480');
if MultiCam vid2=videoinput('winvideo',2,'MJPG_640x480');end
disp('Camera activated.');

choice1 = questdlg('Initialize background?','warning','Confirm','Negative','Negative');
switch choice1
 case 'Confirm'
  check1=false;
  check2=false
  while ~(check1==true && check2==true)
  choice2=questdlg('Get snapshot of background.','...','Confirm','Confirm');
  switch choice2
   case 'Confirm'
    if (check1==false)
     background=getsnapshot(vid1);
     background_hsv=rgb2hsv(background);
     background=im2double(background);
    end
    if (MultiCam && check2==false)
     background2=getsnapshot(vid2);
     background2_hsv=rgb2hsv(background2);
     background2=im2double(background2);
    end
    disp('Background saved.');
    %imshow_union(background,background2);
    if (check1==false)
     imshow(background);
     title('background TBD');
     choice3 = questdlg('Background for cam1 qualified?','...','Confirm','Again','Again');
     switch choice3
      case 'Again'
       check1=false;
      case 'Confirm'
       check1=true;
     end
    end
    if (MultiCam && check2==false)
     imshow(background2);
     title('background TBD');
     choice3 = questdlg('Background for cam2 qualified?','...','Confirm','Again','Again');
     switch choice3
      case 'Again'
       check2=false;
      case 'Confirm'
       check2=true;
     end
    end
  end
  end
 case 'Negative'
  %continue;
end

while (true)
 frame1=getsnapshot(vid1);
 frame1_hsv=rgb2hsv(frame1);
 frame1=im2double(frame1);
 frame1_cut=frame1;
 
 if MultiCam
  frame2=getsnapshot(vid2);
  if (presentation==false)
   if (WhetherCut)
    subplot(241),imshow(frame1),title('origin frame');
    subplot(245),imshow(frame2),title('origin frame');
   else
    subplot(231),imshow(frame1),title('origin frame');
    subplot(234),imshow(frame2),title('origin frame');
   end
  else
  end
  frame2_hsv=rgb2hsv(frame2);
  frame2=im2double(frame2);
  frame2_cut=frame2;
 else 
  subplot(3,3,2),imshow(frame1),title('origin frame');
 end

 for i=1:m
  for j=1:n
   %
   %RGB cut 0.03
   diff=(frame1(i,j,1)-background(i,j,1))^2+(frame1(i,j,2)-background(i,j,2))^2+(frame1(i,j,3)-background(i,j,3))^2;
   if diff<shed_bg 
    frame1_cut(i,j,:)=[255;255;255];
   end
  end
 end

 if MultiCam
  for i=1:m
   for j=1:n
    %RGB cut 0.03
    diff=(frame2(i,j,1)-background2(i,j,1))^2+(frame2(i,j,2)-background2(i,j,2))^2+(frame2(i,j,3)-background2(i,j,3))^2;
    if diff<shed_bg 
     frame2_cut(i,j,:)=[255;255;255];
    end
   end
  end
  if (WhetherCut)
   subplot(242),imshow(frame1_cut),title('cut');
   subplot(246),imshow(frame2_cut),title('cut');
  end
 else
  subplot(3,3,3),imshow(frame1_cut),title('cut');
 end 
 
 if (MultiCam)
  frame1_cut2=rgb2gray(frame1_cut);
  frame2_cut2=rgb2gray(frame2_cut);
  %d=imdistline; 
  if precision_flag==false 
   check=false;
   while check==false   
    [centers, radii, metric] = imfindcircles(frame1_cut2,[30 65],'ObjectPolarity','dark','Sensitivity',cir_precision);
    [centers2, radii2, metric2] = imfindcircles(frame2_cut2,[30 65],'ObjectPolarity','dark','Sensitivity',cir_precision);
    if (WhetherCut)
    subplot(243),imshow(frame1),viscircles(centers, radii,'EdgeColor','b'),title('candidates');
    subplot(247),imshow(frame2),viscircles(centers2, radii2,'EdgeColor','b'),title('candidates'); 
    else
    subplot(232),imshow(frame1),viscircles(centers, radii,'EdgeColor','b'),title('candidates');
    subplot(235),imshow(frame2),viscircles(centers2, radii2,'EdgeColor','b'),title('candidates');  
    end
    %subplot(3,3,4),imshow(frame1),viscircles(centers, radii,'EdgeColor','b');
    str = sprintf('Circle precision test.(%f)',cir_precision);
    choice2 = questdlg(str,'...','More precision','Less precision','Confirm','Confirm'); 
    switch choice2
     case 'Confirm'
      check=true;
      precision_flag=true;
     case 'More precision'
      cir_precision=cir_precision-0.001;
     case 'Less precision'
      cir_precision=cir_precision+0.001;
    end
   end
  else
   if (Morecircles==false)
     [centers, radii, metric] = imfindcircles(frame1_cut2,[30 65],'ObjectPolarity','dark','Sensitivity',cir_precision);
     [centers2, radii2, metric2] = imfindcircles(frame2_cut2,[30 65],'ObjectPolarity','dark','Sensitivity',cir_precision);
     subplot(243),imshow(frame1),viscircles(centers, radii,'EdgeColor','b'),title('candidates');
     subplot(247),imshow(frame2),viscircles(centers2, radii2,'EdgeColor','b'),title('candidates');
   else
     if (WhetherCut)
     [centers, radii, metric] = imfindcircles(frame1_cut2,[30 65],'ObjectPolarity','dark','Sensitivity',cir_precision);
     [centers2, radii2, metric2] = imfindcircles(frame2_cut2,[30 65],'ObjectPolarity','dark','Sensitivity',cir_precision);
     [centers_s, radii_s, metric_s] = imfindcircles(frame1,[30 65],'ObjectPolarity','dark','Sensitivity',cir_precision+MorecirclesNum);
     [centers2_s, radii2_s, metric2_s] = imfindcircles(frame2,[30 65],'ObjectPolarity','dark','Sensitivity',cir_precision+MorecirclesNum);
     subplot(243),imshow(frame1),viscircles(centers_s, radii_s,'EdgeColor','b'),title('candidates');
     subplot(247),imshow(frame2),viscircles(centers2_s, radii2_s,'EdgeColor','b'),title('candidates');
     else
     [centers, radii, metric] = imfindcircles(frame1_cut2,[30 65],'ObjectPolarity','dark','Sensitivity',cir_precision);
     [centers2, radii2, metric2] = imfindcircles(frame2_cut2,[30 65],'ObjectPolarity','dark','Sensitivity',cir_precision);
     [centers_s, radii_s, metric_s] = imfindcircles(frame1,[30 65],'ObjectPolarity','dark','Sensitivity',cir_precision+MorecirclesNum);
     [centers2_s, radii2_s, metric2_s] = imfindcircles(frame2,[30 65],'ObjectPolarity','dark','Sensitivity',cir_precision+MorecirclesNum);
     subplot(232),imshow(frame1),viscircles(centers_s, radii_s,'EdgeColor','b'),title('candidates');
     subplot(235),imshow(frame2),viscircles(centers2_s, radii2_s,'EdgeColor','b'),title('candidates'); 
     end
   end
  end
 else
  frame1_cut2=rgb2gray(frame1_cut);
  %d=imdistline; 
  if precision_flag==false 
   check=false;
   while check==false
    [centers, radii, metric] = imfindcircles(frame1_cut2,[30 65],'ObjectPolarity','dark','Sensitivity',cir_precision);
    subplot(3,3,4),imshow(frame1),viscircles(centers, radii,'EdgeColor','b');
    title('candidates');
    str = sprintf('Precision test.(%f)',cir_precision);
    choice2 = questdlg(str,'...','More precision','Less precision','Confirm','Confirm'); 
    switch choice2
     case 'Confirm'
      check=true;
      precision_flag=true;
     case 'More precision'
      cir_precision=cir_precision-0.001;
     case 'Less precision'
      cir_precision=cir_precision+0.001;
    end
   end
  else
   [centers, radii, metric] = imfindcircles(frame1_cut2,[30 65],'ObjectPolarity','dark','Sensitivity',cir_precision);
   subplot(3,3,4),imshow(frame1),viscircles(centers, radii,'EdgeColor','b');
   title('candidates');
  end
 end

 if WaveletCheck==true
  if MultiCam
   frame1_gray=rgb2gray(frame1);
   [x_frame,map]=gray2ind(frame1_gray,256);
   [thr,sorh,keepapp] = ddencmp('den','wv',x_frame);
   xd_frame = wdencmp('gbl',x_frame,'sym4',2,thr,sorh,keepapp);
   sm = size(map,1);
   frame1_gray=ind2gray(wcodemat(xd_frame,sm),gray(256));
   
   frame2_gray=rgb2gray(frame2);
   [x_frame,map]=gray2ind(frame2_gray,256);
   [thr,sorh,keepapp] = ddencmp('den','wv',x_frame);
   xd_frame = wdencmp('gbl',x_frame,'sym4',2,thr,sorh,keepapp);
   sm = size(map,1);
   frame2_gray=ind2gray(wcodemat(xd_frame,sm),gray(256));
  else
   frame1_gray=rgb2gray(frame1);
   [x_frame,map]=gray2ind(frame1_gray,256);

   [thr,sorh,keepapp] = ddencmp('den','wv',x_frame);
   xd_frame = wdencmp('gbl',x_frame,'sym4',2,thr,sorh,keepapp);
   sm = size(map,1);
   frame1_gray=ind2gray(wcodemat(xd_frame,sm),gray(256));
   subplot(335), imshow(frame1_gray), title('Denoised');
  end
 end

 if (flag==false)
 choice1 = questdlg('Improve database?','...','Confirm','Negative','Negative');
 if strcmp(choice1,'Confirm')==1 
  ImproveMode = true;
  fid=fopen('database.txt','a+t');
 else
  ImproveMode = false;
  fid=fopen('database.txt','r+');
 end
 end

 if (ImproveMode==false && flag==false)
  num=0;
  line=fgetl(fid);
  if (~rgb)
   while (~feof(fid))
   if (isempty(line)==true) 
    line=fgetl(fid);
    continue;
   end
   num=num+1;
   [b,c]=strtok(line,' ');
   Group(num)=str2num(b);
   c=strtrim(c);
   [b,c]=strtok(c,' ');
   Pixelnum(num)=str2num(b);
   c=strtrim(c);
   [b,c]=strtok(c,' ');
   Col(num)=str2num(b);
   c=strtrim(c);
   Metric(num)=str2num(c);
   line=fgetl(fid);
   end
   fclose(fid);
  else %read rgb
   while (~feof(fid))
   if (isempty(line)==true) 
    line=fgetl(fid);
    continue;
   end
   num=num+1;
   [b,c]=strtok(line,' ');
   Group(num)=str2num(b);
   c=strtrim(c);
   [b,c]=strtok(c,' ');
   Pixelnum(num)=str2num(b);
   c=strtrim(c);
   [b,c]=strtok(c,' ');
   Colr(num)=str2num(b);
   c=strtrim(c);
   [b,c]=strtok(c,' ');
   Colg(num)=str2num(b);
   c=strtrim(c);
   [b,c]=strtok(c,' ');
   Colb(num)=str2num(b);
   c=strtrim(c);
   Metric(num)=str2num(c);
   line=fgetl(fid);
   end
   fclose(fid);
  end
  
  if (~rgb)
   traindata=[Pixelnum',Col',Metric'];
  else
   traindata=[Pixelnum',Colr',Colg',Colb',Metric'];
  end
  SVMModel=fitcsvm(traindata,Group,'Standardize',true,'KernelFunction','RBF','KernelScale','auto');
  disp('SVMModel trained.');
 end
 
 pixelnum=[];
 col=[];col_num=0;
 colr=[];colg=[];colb=[];
 if (flag==false) 
  pause(2);
 end
 
 if MultiCam
  num=1;
  while num<=size(centers,1)
  frame1_gr=frame1;
  pixelnum=[pixelnum 1];
  col=[col 0];col_num=0;
  colr=[colr 0];
  colg=[colg 0];
  colb=[colb 0];
   for i=1:m
    for j=1:n
     CheckMatrix(i,j)=false;
    end
   end
   for i=-round(radii(num)*RadiiRatio):round(radii(num)*RadiiRatio)
    for j=-round(radii(num)*RadiiRatio):round(radii(num)*RadiiRatio)
     x = round(centers(num,2))+i;
     y = round(centers(num,1))+j;
     if (x>0)&&(y>0)&&(x<m+1)&&(y<n+1)&&(CheckMatrix(x,y)==false)
      listx=[x];
      listy=[y];
      head=1;
      tail=1;
      x0=x;y0=y;
      while head<=tail
       x=listx(head);
       y=listy(head);
       for k=1:4
        tx=listx(head)+dirc(k,1);
        ty=listy(head)+dirc(k,2); 
        if (tx<1)||(ty<1)||(tx>m)||(ty>n)||((tx-x0)^2+(ty-y0)^2>1*radii(num).^2)...
         ||(CheckMatrix(tx,ty)==true) continue;end
        if ((frame1_cut(tx,ty,1)==255)&&(frame1_cut(tx,ty,2)==255)&&(frame1_cut(tx,ty,3)==255)) continue;end

        if WaveletCheck==false
         diff=(frame1(x,y,1)-frame1(tx,ty,1))^2+(frame1(x,y,2)-frame1(tx,ty,2))^2+(frame1(x,y,3)-frame1(tx,ty,3))^2;
         if (diff>SplitShed) continue;end
        else
         diff=abs(frame1_gray(x,y)-frame1_gray(tx,ty));
         if (diff>SplitShed_denoise) continue;end
        end
        CheckMatrix(tx,ty)=true;
        frame1_gr(tx,ty,:)=[255;0;0];
        tail=tail+1;
        listx=[listx tx];
        listy=[listy ty];
        frame1_gr(tx,ty,:)=[255;0;0];
        pixelnum(num)=pixelnum(num)+1;
        col(num)=(col(num)*col_num+frame1_cut2(tx,ty))/(col_num+1);
        colr(num)=(colr(num)*col_num+frame1(tx,ty,1))/(col_num+1);
        colg(num)=(colg(num)*col_num+frame1(tx,ty,2))/(col_num+1);
        colb(num)=(colb(num)*col_num+frame1(tx,ty,3))/(col_num+1);
        col_num=col_num+1;
       end
       head=head+1;
      end
     end
    end
   end
   if (ImproveMode==true)
    subplot(248),imshow(White);
    subplot(244),imshow(frame1_gr),viscircles(centers(num,:), radii(num),'EdgeColor','b'),title('TBD head');
    choice4 = questdlg('Is this candidate a head?','...','Yes','No','Pass','Pass');
    switch choice4
     case 'Yes'
      group(num)=1;
      if (~rgb) 
       fprintf(fid,'%d %f %f %f\n',1,pixelnum(num),col(num),metric(num));
      else
       fprintf(fid,'%d %f %f %f %f %f\n',1,pixelnum(num),colr(num),colg(num),colb(num),metric(num));
      end
     case 'No'
      group(num)=0;
      if (~rgb) 
       fprintf(fid,'%d %f %f %f\n',0,pixelnum(num),col(num),metric(num));
      else
       fprintf(fid,'%d %f %f %f %f %f\n',0,pixelnum(num),colr(num),colg(num),colb(num),metric(num));
      end
     case 'Pass'
    end
   end
   num=num+1;
  end
  pixelnum2=[];
  col2=[];col2_num=0;
  colr2=[];
  colg2=[];
  colb2=[];
 
  num2=1;
  while num2<=size(centers2,1)
  frame2_gr=frame2;
  pixelnum2=[pixelnum2 1];
  col2=[col2 0];col2_num=0;
  colr2=[colr2 0];
  colg2=[colg2 0];
  colb2=[colb2 0];
   for i=1:m
    for j=1:n
     CheckMatrix(i,j)=false;
    end
   end
   for i=-round(radii2(num2)*RadiiRatio):round(radii2(num2)*RadiiRatio)
    for j=-round(radii2(num2)*RadiiRatio):round(radii2(num2)*RadiiRatio)
     x = round(centers2(num2,2))+i;
     y = round(centers2(num2,1))+j;
     if (x>0)&&(y>0)&&(x<m+1)&&(y<n+1)&&(CheckMatrix(x,y)==false)
      listx=[x];
      listy=[y];
      head=1;
      tail=1;
      x0=x;y0=y;
      while head<=tail
       x=listx(head);
       y=listy(head);
       for k=1:4
        tx=listx(head)+dirc(k,1);
        ty=listy(head)+dirc(k,2); 
        if (tx<1)||(ty<1)||(tx>m)||(ty>n)||((tx-x0)^2+(ty-y0)^2>1*radii2(num2).^2)...
         ||(CheckMatrix(tx,ty)==true) continue;end
        if ((frame2_cut(tx,ty,1)==255)&&(frame2_cut(tx,ty,2)==255)&&(frame2_cut(tx,ty,3)==255)) continue;end

        if WaveletCheck==false
         diff=(frame2(x,y,1)-frame2(tx,ty,1))^2+(frame2(x,y,2)-frame2(tx,ty,2))^2+(frame2(x,y,3)-frame2(tx,ty,3))^2;
         if (diff>SplitShed) continue;end
        else
         diff=abs(frame2_gray(x,y)-frame2_gray(tx,ty));
         if (diff>SplitShed_denoise) continue;end
        end
        CheckMatrix(tx,ty)=true;
        frame2_gr(tx,ty,:)=[255;0;0];
        tail=tail+1;
        listx=[listx tx];
        listy=[listy ty];
        frame2_gr(tx,ty,:)=[255;0;0];
        pixelnum2(num2)=pixelnum2(num2)+1;
        col2(num2)=(col2(num2)*col2_num+frame2_cut2(tx,ty))/(col2_num+1);
        colr2(num2)=(colr2(num2)*col2_num+frame2(tx,ty,1))/(col2_num+1);
        colg2(num2)=(colg2(num2)*col2_num+frame2(tx,ty,2))/(col2_num+1);
        colb2(num2)=(colb2(num2)*col2_num+frame2(tx,ty,3))/(col2_num+1);
        col2_num=col2_num+1;
       end
       head=head+1;
      end
     end
    end
   end
   if (ImproveMode==true)
    subplot(244),imshow(White);
    subplot(248),imshow(frame2_gr),viscircles(centers2(num2,:), radii2(num2),'EdgeColor','b'),title('TBD head');
    choice4 = questdlg('Is this candidate a head?','...','Yes','No','Pass','Pass');
    switch choice4
     case 'Yes'
      group2(num2)=1;
      if (~rgb)
       fprintf(fid,'%d %f %f %f\n',1,pixelnum2(num2),col2(num2),metric2(num2));
      else
       fprintf(fid,'%d %f %f %f %f %f\n',1,pixelnum2(num2),colr2(num2),colg2(num2),colb2(num2),metric2(num2));
      end
     case 'No'
      group2(num2)=0;
      if (~rgb)
       fprintf(fid,'%d %f %f %f\n',0,pixelnum2(num2),col2(num2),metric2(num2));
      else
       fprintf(fid,'%d %f %f %f %f %f\n',0,pixelnum2(num2),colr2(num2),colg2(num2),colb2(num2),metric2(num2));
      end
     case 'Pass'
    end
   end
   num2=num2+1;
  end  
 else 
  num=1;
  while num<=size(centers,1)
  frame1_gr=frame1;
  pixelnum=[pixelnum 1];
  col=[col 0];col_num=0;
  colr=[colr 0];
  colg=[colg 0];
  colb=[colb 0];
   for i=1:m
    for j=1:n
     CheckMatrix(i,j)=false;
    end
   end
   for i=-round(radii(num)*RadiiRatio):round(radii(num)*RadiiRatio)
    for j=-round(radii(num)*RadiiRatio):round(radii(num)*RadiiRatio)
     x = round(centers(num,2))+i;
     y = round(centers(num,1))+j;
     if (x>0)&&(y>0)&&(x<m+1)&&(y<n+1)&&(CheckMatrix(x,y)==false)
      listx=[x];
      listy=[y];
      head=1;
      tail=1;
      x0=x;y0=y;
      while head<=tail
       x=listx(head);
       y=listy(head);
       for k=1:4
        tx=listx(head)+dirc(k,1);
        ty=listy(head)+dirc(k,2); 
        if (tx<1)||(ty<1)||(tx>m)||(ty>n)||((tx-x0)^2+(ty-y0)^2>1*radii(num).^2)...
         ||(CheckMatrix(tx,ty)==true) continue;end
        if ((frame1_cut(tx,ty,1)==255)&&(frame1_cut(tx,ty,2)==255)&&(frame1_cut(tx,ty,3)==255)) continue;end

        if WaveletCheck==false
         diff=(frame1(x,y,1)-frame1(tx,ty,1))^2+(frame1(x,y,2)-frame1(tx,ty,2))^2+(frame1(x,y,3)-frame1(tx,ty,3))^2;
         if (diff>SplitShed) continue;end
        else
         diff=abs(frame1_gray(x,y)-frame1_gray(tx,ty));
         if (diff>SplitShed_denoise) continue;end
        end

        CheckMatrix(tx,ty)=true;
        frame1_gr(tx,ty,:)=[255;0;0];
        tail=tail+1;
        listx=[listx tx];
        listy=[listy ty];
        frame1_gr(tx,ty,:)=[255;0;0];
        pixelnum(num)=pixelnum(num)+1;
        col(num)=(col(num)*col_num+frame1_cut2(tx,ty))/(col_num+1);
        colr(num)=(colr(num)*col_num+frame1(tx,ty,1))/(col_num+1);
        colg(num)=(colg(num)*col_num+frame1(tx,ty,2))/(col_num+1);
        colb(num)=(colb(num)*col_num+frame1(tx,ty,3))/(col_num+1);
        col_num=col_num+1;
       end
       head=head+1;
      end
     end
    end
   end
   if (ImproveMode==true)
    subplot(336),imshow(frame1_gr),viscircles(centers(num,:), radii(num),'EdgeColor','b');
    title('TBD head');
    choice4 = questdlg('Is this candidate a head?','...','Yes','No','Pass','Pass');
    switch choice4
     case 'Yes'
      group(num)=1;
      if (~rgb)
       fprintf(fid,'%d %f %f %f\n',1,pixelnum(num),col(num),metric(num));
      else
       fprintf(fid,'%d %f %f %f %f %f\n',1,pixelnum(num),colr(num),colg(num),colb(num),metric(num));
      end
     case 'No'
      group(num)=0;
      if (~rgb)
       fprintf(fid,'%d %f %f %f\n',0,pixelnum(num),col(num),metric(num));
      else
       fprintf(fid,'%d %f %f %f %f %f\n',0,pixelnum(num),colr(num),colg(num),colb(num),metric(num));
      end
     case 'Pass'
    end
   end
   num=num+1;
  end
 end

 ConfirmNum=0;
 if MultiCam
  if (ImproveMode==false && ~isempty(metric))
   if (~rgb)
    Testdata=[pixelnum',col',metric];
   else
    Testdata=[pixelnum',colr',colg',colb',metric];
   end
   [group,confd]=predict(SVMModel,Testdata);
   for i=1:length(group)
    if (centers(i,1)<radii(i) || n-centers(i,1)<radii(i) || centers(i,2)<radii(i) || m-centers(i,2)<radii(i))
     group(i)=0;
    end
   end
   
   for i=1:length(group)-1
    for j=i+1:length(group)
     if (group(i)==0 || group(j)==0) 
      continue;
     end
     dis=sqrt((centers(i,1)-centers(j,1))^2+(centers(i,2)-centers(j,2))^2);
     if dis>radii(i)+radii(j) continue;end
     if radii(i)<radii(j) radiiSmall=radii(i); else radiiSmall=radii(j);end
     if dis<abs(radii(i)-radii(j)) 
      if radii(i)<radii(j) 
       group(i)=0;
      else
       group(j)=0;
      end
     end
     theta1=acos((radii(i)^2+dis^2-radii(j)^2)/(2*radii(i)*dis));
     theta2=acos((radii(j)^2+dis^2-radii(i)^2)/(2*radii(j)*dis));
     Sinter=theta1*radii(i)^2+theta2*radii(j)^2-0.5*radii(i)^2*sin(2*theta1)-0.5*radii(j)^2*sin(2*theta2);    
     if (Sinter/(pi*radiiSmall^2)>CircleInterRatio)
      if abs(confd(i))<abs(confd(j)) 
       group(i)=0;
      else
       group(j)=0;
      end
     end
    end
   end

   if (WhetherCut)
   subplot(244),imshow(frame1);
   else
   subplot(233),imshow(frame1); 
   end
   for i=1:length(group)
    if group(i)==1 
     ConfirmNum=ConfirmNum+1;
     viscircles(centers(i,:), radii(i),'EdgeColor','b');
    end
   end
   title('detected');
  end
  
  % for another cam
  
  if (ImproveMode==false && ~isempty(metric2))
   if (~rgb)
    Testdata=[pixelnum2',col2',metric2];
   else
    Testdata=[pixelnum2',colr2',colg2',colb2',metric2];
   end
   [group,confd]=predict(SVMModel,Testdata);

   for i=1:length(group)
    if (centers2(i,1)<radii2(i) || n-centers2(i,1)<radii2(i) || centers2(i,2)<radii2(i) || m-centers2(i,2)<radii2(i))
     group(i)=0;
    end
   end
   
   for i=1:length(group)-1
    for j=i+1:length(group)
     if (group(i)==0 || group(j)==0) 
      continue;
     end
     dis=sqrt((centers2(i,1)-centers2(j,1))^2+(centers2(i,2)-centers2(j,2))^2);
     if dis>radii2(i)+radii2(j) continue;end
     if radii2(i)<radii2(j) radiiSmall=radii2(i); else radiiSmall=radii2(j);end
     if dis<abs(radii2(i)-radii2(j)) 
      if radii2(i)<radii2(j) 
       group(i)=0;
      else
       group(j)=0;
      end
     end
     theta1=acos((radii2(i)^2+dis^2-radii2(j)^2)/(2*radii2(i)*dis));
     theta2=acos((radii2(j)^2+dis^2-radii2(i)^2)/(2*radii2(j)*dis));
     Sinter=theta1*radii2(i)^2+theta2*radii2(j)^2-0.5*radii2(i)^2*sin(2*theta1)-0.5*radii2(j)^2*sin(2*theta2);    
     if (Sinter/(pi*radiiSmall^2)>CircleInterRatio)
      if abs(confd(i))<abs(confd(j)) 
       group(i)=0;
      else
       group(j)=0;
      end
     end
    end
   end

   if (WhetherCut)
   subplot(248),imshow(frame2);
   else
   subplot(236),imshow(frame2); 
   end
   for i=1:length(group)
    if group(i)==1 
     ConfirmNum=ConfirmNum+1;
     viscircles(centers2(i,:), radii2(i),'EdgeColor','b');
    end
   end
   title('detected');
  end
  
 else %multicam split line
  
  if (ImproveMode==false && ~isempty(metric))
   if (~rgb)
    Testdata=[pixelnum',col',metric];
   else
    Testdata=[pixelnum',colr',colg',colb',metric];
   end
   [group,confd]=predict(SVMModel,Testdata);

   for i=1:length(group)
    if (centers(i,1)<radii(i) || n-centers(i,1)<radii(i) || centers(i,2)<radii(i) || m-centers(i,2)<radii(i))
     group(i)=0;
    end
   end
   
   for i=1:length(group)-1
    for j=i+1:length(group)
     if (group(i)==0 || group(j)==0) 
      continue;
     end
     dis=sqrt((centers(i,1)-centers(j,1))^2+(centers(i,2)-centers(j,2))^2);
     if dis>radii(i)+radii(j) continue;end
     if radii(i)<radii(j) radiiSmall=radii(i); else radiiSmall=radii(j);end
     if dis<abs(radii(i)-radii(j)) 
      if radii(i)<radii(j) 
       group(i)=0;
      else
       group(j)=0;
      end
     end
     theta1=acos((radii(i)^2+dis^2-radii(j)^2)/(2*radii(i)*dis));
     theta2=acos((radii(j)^2+dis^2-radii(i)^2)/(2*radii(j)*dis));
     Sinter=theta1*radii(i)^2+theta2*radii(j)^2-0.5*radii(i)^2*sin(2*theta1)-0.5*radii(j)^2*sin(2*theta2);    
     if (Sinter/(pi*radiiSmall^2)>CircleInterRatio)
      if abs(confd(i))<abs(confd(j)) 
       group(i)=0;
      else
       group(j)=0;
      end
     end
    end
   end

   subplot(336),imshow(frame1);
   for i=1:length(group)
    if group(i)==1 
     ConfirmNum=ConfirmNum+1;
     viscircles(centers(i,:), radii(i),'EdgeColor','b');
    end
   end
   title('detected');
  end
 end %multicam end
 
 if (ImproveMode==true)
  choice4 = questdlg('One more frame?','...','Yes','Quit','Quit');
  if strcmp(choice4,'Quit')==1 
   fprintf(fid,'\n');
   fclose(fid);
   return;
  end
 end
 
 if (WebTransfer==true)
  if (MultiCam==true)
   k=num2str(ConfirmNum);
   url = 'http://vitas.runtianz.cn/?ssid=cbdptbtptpbcptdtptp&data=';
   url = strcat(url,k);
   options = weboptions('RequestMethod', 'post');
   webread(url);
  else
   k=num2str(ConfirmNum);
   url = 'http://vitas.runtianz.cn/?ssid=cbdptbtptpbcptdtptp&data=';
   url = strcat(url,k);
   options = weboptions('RequestMethod', 'post');
   webread(url);
  end
 end
 
 flag=true;
end

function imshow_union(b1,b2)
 b2=fliplr(b2);
 b2=flipud(b2);
 imshow([b2;b1]);
end
