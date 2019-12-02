function p = getrmat(x)

global CTRL_PARS;

nj(1) = 31; nj(2) = 28; nj(3) = 31; nj(4) = 30; nj(5) = 31; nj(6) = 30; nj(7:8) = 31;
nj(9) = 30; nj(10) = 31; nj(11) = 30; nj(12) = 31;
if (CTRL_PARS.Do_Date == 0);
    for n = 1:length(x)
        p(n,1) = x(n,9);
        p(n,2) = x(n,14);
        p(n,3) = x(n,6);
        p(n,4) = x(n,17);
        p(n,5) = x(n,19);
        p(n,6) = x(n,20);
        p(n,7) = x(n,21);
        p(n,8) = x(n,3);
        p(n,9) = x(n,4);
        p(n,10) = 2008 - x(n,5);
        if (x(n,5)==-1)
            p(n,10) = 2008;
        end;
        p(n,11) = 2008 - x(n,22);
        if (x(n,22)==-1)
            p(n,11) = 2008;
        end;
        p(n,12) = x(n,16);
        if(x(n,17)==1)
            p(n,12) = p(n,12)+25000;          
        end;
        p(n,13) = x(n,2);
        p(n,14) = x(n,1);
        switch (x(n,10))
            case -1
                switch (x(n,8))
                    case -1
                        x(n,8) = 0;
                        x(n,10) = 0;
                end;
            case 0
                 switch (x(n,8))
                    case -1
                        x(n,10) = 0;
                        x(n,8) = 0;
                 end;
                 ein = x(n,8)/(1/12);
                 eip = (ein/p(n,1))*100;
            otherwise
                 ein = x(n,19)/(x(n,9)/12);
                 eip = (ein/p(n,1))*100;
        end;    
        p(n,15) = x(n,10);
        p(n,16) = x(n,8);    
        p(n,17) = ein;
        p(n,18) = eip;
    end;
elseif (CTRL_PARS.Do_Date == 1)
    for n = 1:length(x)
        p(n,1) = x(n,9);
        p(n,2) = x(n,14);
        p(n,3) = x(n,6);
        p(n,4) = x(n,17);
        p(n,5) = x(n,19);
        p(n,6) = x(n,20);
        p(n,7) = x(n,21);
        p(n,8) = x(n,3);
        p(n,9) = x(n,4);
        p(n,10) = 2008 - x(n,5);
        if (x(n,5)==-1)
            p(n,10) = 2008;
        end;
        p(n,11) = 2008 - x(n,22);
        if (x(n,22)==-1)
            p(n,11) = 2008;
        end;
        p(n,12) = x(n,16);
        if(x(n,17)==1)
            p(n,12) = p(n,12)+25000;          
        end;
        p(n,13) = x(n,2);
        p(n,14) = x(n,1);
        redmo = x(n,12);
        redday = x(n,13);
        redyr = x(n,11);
        if (redyr == x(n,5));
           if ((redyr==2004)||(redyr==2000)||(redyr==1996))
               nj(2) = 29;
           end;
           redday = redday -1;
           mofac_rem = redday/nj(redmo);          
        elseif (redyr > x(n,5));
           if ((redyr==2004)||(redyr==2000)||(redyr==1996))
               nj(2) = 29;
           end;
           if ((x(n,5)==2004)||(x(n,5)==2000)||(x(n,5)==1996))
               nj(2) = 29;
           end;
           redday = redday - 1;
           mofac_rem = redday/nj(redmo);
        end;
        switch (x(n,10))
            case -1
                switch (x(n,8))
                    case -1
                        x(n,8) = 0;
                        x(n,10) = 0;
                end;
            case 0
                mofac = (1/12);
                switch (x(n,8))
                    case -1
                        x(n,8) = 0;
                        x(n,10) = 0;
                 end;
                 ein = x(n,8)/mofac;
                 eip = (ein/p(n,1))*100;
            otherwise
                mofac = (x(n,10)+mofac_rem)/12;
                ein = x(n,8)/mofac;
                eip = (ein/p(n,1))*100;
        end;            
        p(n,15) = x(n,10)+mofac;
        p(n,16) = x(n,8);    
        p(n,17) = ein;
        p(n,18) = eip;
    end;
end;

