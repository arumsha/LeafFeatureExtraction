%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This program is used to finish the task Pattern Recognition's project
% Copyright by Yuita and Ratih
% April 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preprocessing gambar
% resize gambar
function fiturDaun = Preprocessing (inputGambar);
I = imread(inputGambar); %membaca gambar
resizeGambar=imresize(I,0.2);
%%%--imshow(resizeGambar);

% membuat background hitam dan objeknya putih
grayim=rgb2gray(resizeGambar);
I11 = imadjust(grayim,stretchlim(grayim),[]);
level = graythresh(I11);
BWJ = im2bw(I11,level);
dim = size(BWJ);
IN=ones(dim(1),dim(2));
BW=xor(BWJ,IN);  %inverting
figure
subplot(1,2,1), imshow(resizeGambar), title( 'Original Image');
subplot(1,2,2), imshow(BW), title( 'Black and White');
%imshow(BW)

% % mencari panjang dan lebar
[M,N]=size(BW); %ukuran dimensi dari gambar

% mencari kolom yang paling atas dg jumlah >1
i=1; kondisi =0;
  while ( kondisi == 0)
     temp = sum(BW(i,:)); %menjumlahkan angka per kolom
      if temp > 0
          kondisi = 1;
          posatas = i;
      end
      i = i+1;
  end
  % mencari kolom yang paling bawah dg jumlah>1
  i=length(BW(:,1)); kondisi =0;
  while ( kondisi == 0)
     temp = sum(BW(i,:)); % menjumlahkan angka per baris
      if temp > 0
          kondisi = 1;
          posbawah = i;
      end
      i = i-1;
  end
  
% total panjang
panjang = posbawah-posatas;

% mencari baris paling kiri dengan jumlah > 1
i=1; kondisi =0;
  while ( kondisi == 0)
     temp = sum(BW(:,i)); %menjumlahkan angka per kolom
      if temp > 0
          kondisi = 1;
          poskiri = i;
      end
      i = i+1;
  end 
% mencari baris yang paling kanan dg jumlah >1
  i=length(BW(1,:)); kondisi =0;
  while ( kondisi == 0)
     temp = sum(BW(:,i)); % menjumlahkan angka per baris
      if temp > 0
          kondisi = 1;
          poskanan = i;
      end
      i = i-1;
  end
  
% total lebar
lebar = poskanan-poskiri;


% mencari Area
areaBw = regionprops(BW, 'area');
areabw = areaBw.Area;

% mencari perimeter
perimbw = regionprops(BW, 'perimeter');
perim = perimbw.Perimeter;

% mencari centroid
titiktengah = regionprops(BW,'Centroid') ;
centroid = cat(1,titiktengah.Centroid);
imshow(BW)
hold on
plot(centroid(:,1), centroid(:,2),'r*')
hold off

% 
% % ======================================================%
% % melakukan ekstrasi fitur SHAPE
% ***** slimness (panjang daun/ lebar daun) *****
% Slimness  merupakan rasio perbandingan antara 
% panjang daun dengan lebar daun 
  if panjang > lebar
      slimness = panjang / lebar;
    else
      slimness = lebar / panjang;
  end

% form factor/roundness
% Membedakan kemiripan daun dengan bentuk lingkaran
    roundness = (4*pi * areabw) / (perim ^ 2);

% % rectangularity
% Mendeskripsikan  kemiripan antara dua daun 
% dan area empat persegi panjang 
    rectangularity = (panjang * lebar) / areabw;

% % narrow factor
% Rasio antara diameter dan physiological length. 
% Untuk menentukan apakah bentuk helai daun tergolong simetri 
% atau asimetri, jika simetri nilainya 1, 
% jika asimetri lebih dari 1
    narrowfactor = perim / roundness;
    
% % perimeter ratio of diameter
% Untuk mengukur seberapa lonjong daun
    prd = perim/ (panjang +lebar);

% % perimeter ratio of physiological length and width
% Rasio antara perimeter dengan panjang daun 
% ditambahkan dengan lebar daun
    prp = perim / (panjang * lebar) ;



% ======================================================%
% melakukan ekstrasi fitur menggunakan COLOR
% mencari nilai masing-masing channel R, G, dan B
redI = resizeGambar(:,:,1);
greenI = resizeGambar (:,:,2);
blueI = resizeGambar(:,:,3);
% mencari nilai mean pada masing-masing RGB
meanRI = mean(redI(:)); %menan pada R
meanGI = mean(greenI(:)); % mean pada G
meanBI = mean (blueI(:)); % mean pada blue

% ======================================================%
% melakukan ektrasi fitur menggunakan TEKSTUR
% merubah warna daun menjadi warna binary yaitu black and white
gambarBW = im2bw(resizeGambar);
simpanGambarBW = 'gambarBW.jpg';
imwrite(gambarBW, simpanGambarBW);
%mencari gliding box lacunarity
%%
% Author: Tegy J. Vadakkan
% Date: 09/08/2009
% Gliding box lacunarity algorithm based on the ideas presented in the
% paper by Tolle et al., Physica D, 237, 306-315, 2008
% input is the binary file with 0's and 1's. 0's represent the holes or the
% lacunae
% the output M gives the lacunarity at various box lengths (edge sizes are multiples of 2)
%%
a = imread(simpanGambarBW);
[rows, cols] = size(a);
a = 1 - a;
%%
n = 2;
while(n <= rows)
nn = n-1;
rnn = rows - nn;
index = uint8(log2(n));
count(index)= power(rnn,2);
sigma(index) = 0.0;
sigma2(index) = 0.0;
for i=1:rnn
    for j=1:rnn
        sums = sum(sum(a(i:i+nn,j:j+nn)));
        sigma(index) = sigma(index) + sums;
        sigma2(index) = sigma2(index) + power(sums,2);
    end
end
n = n * 2;
end
%%
for i=1:index
    M(i,1)= (count(i)*sigma2(i))/(power(sigma(i),2));
end

meanLacunarity= mean(M,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% concatenation all feature
fiturDaun = [slimness;roundness;rectangularity;narrowfactor;prd;prp;meanRI;meanGI;meanBI;meanLacunarity]