% Niezawodnoœæ i Diagnostyka Uk³adów Cyfrowych - PROJEKT 2
% Wtorek TP 15:15
% Temat: BCH
%
% Autorzy:
% Dariusz Tomaszewski, 235565
% Justyna Skalska, 225942
% Alicja Wróbel, 238894
% 
%%
clear all;

K = zeros(0);
N = zeros(0);
BER = zeros(0);
E = zeros(0);

tests = 5; % iloœæ testów
Pp = 0.05; % prawd. przek³amania
m = 5; % od którego "m" zaczynamy

file=fopen('m5678.txt','at');
fprintf(file,'K;N;BER;E\n');
for test=1:tests
    while(m >= 5 && m <=8)
        if m==5 %n=31
            k=[26 21 16 11 6];
            t=[1 2 3 5 7];
        end
        if m==6 %n=63
            k=[57 51 45 39 36 30 24 18 16 10 7];
            t=[1 2 3 4 5 6 7 10 11 13 15];
        end
        if m==7 %n=127
            k=[120 113 106 99 92 85 78 71 64 57 50 43 36 29 22 15 8];
            t=[1 2 3 4 5 6 7 9 10 11 13 14 15 21 23 27 31];
        end
        if m==8 %n=255
            k=[247 239 231 223 215 207 199 191 187 179 171 163 155 147 139 131 123 115 107 99 91 87 79 71 63 55 47 45 37 29 21 13 9];
            t=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 18 19 21 22 23 25 26 27 29 30 31 42 43 45 47 55 59 63];
        end
        n=2^m-1;
        for i=1:numel(k)
            
            % Generowanie
            msg = gf(randi(1,k(i)));
            % Generowanie wielomianu
            [genpoly, t(i)] = bchgenpoly(n,k(i));
            
            % Kodowanie
            code = bchenc(msg,n,k(i));
            
            % Dodawanie zak³óceñ
            noisecode = disrupt(code,n,k(i),Pp);
            
            % Dekodowanie
            [newmsg,err,corrected_code] = bchdec(noisecode,n,k(i));
            
            BER_one(i,test) = numel(find(msg ~= newmsg))/(k(i)*n); % BER
            E_one(i,test) = (k(i)^2-numel(find(msg ~= newmsg)))/(k(i)*n); % Efektywnoœæ
        end
        avrBER = mean(BER_one,2);
        avrE = mean(E_one,2);
        for i = 1: numel(avrE)
            fprintf(file,'%d;%d;%f;%f\n',k(i),n,avrBER(i),avrE(i)); % Wypisanie do pliku
            K=[K cellstr(num2str(k(i)))]; % Generowane do wykresu
            N=[N cellstr(num2str(n))]; % Generowane do wykresu
            BER=[BER avrBER(i)]; % Generowane do wykresu
            E=[E avrE(i)]; % Generowane do wykresu
        end
        disp('m='); disp(m); disp(' zakonczone!\n');
        m=m+1; % Kolejne "m"
    end
end
fclose(file);
%%
%uiimport('-file');
%%
scatter(E,BER,10,'filled');
xlabel('E [%]');
ylabel('BER [%]');
title("Obszar Pareto");
grid on;
K_string = char(K);
N_string = char(N);
points = strcat('  (', N_string, ',' , K_string, ')');
t = text(E,BER,points,'FontSize',6);
fclose('all');

%%
function noisecode = disrupt(code,n,k,pp)
    noise_number = floor(n*k*pp); % Iloœæ zak³óceñ
    noise_num_row = randi(k,1,noise_number);
    noise_num_col = randi(n,1,noise_number);
    noise_matrix = zeros(k,n);
    for i=1:noise_number
        noise_matrix(noise_num_row(i),noise_num_col(i)) = 1;
    end
    noisecode = code;
    for i = 1:k
        for j = 1:n
            if(noise_matrix(i,j) == 1)
                %noisecode(i,j) = ~noisecode(i,j);
                if(noisecode(i,j) == 1)
                    noisecode(i,j) = 0;
                else
                    noisecode(i,j) = 1;
                end
            end
        end
    end
end