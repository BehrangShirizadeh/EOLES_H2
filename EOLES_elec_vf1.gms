*-------------------------------------------------------------------------------
*                                Defining the sets
*-------------------------------------------------------------------------------
sets     i                                               /0*8759/
         h(i)                                            /0*8735/
         first(h)        'first hour'
         last(h)         'last hour'
         m               'month'                         /1*12/
         tec             'technology'                    /offshore_f, offshore_g, onshore, pv_g, pv_c, river, lake, biogas1, biogas2, biogas3, ocgt, ccgt, ccgt-ccs, ngas1, ngas2, ngas3, nuc, phs, phs_n,  battery1, battery4, methanation1, methanation2, methanation3, hydrogen, SC/
         gen(tec)        'power plants'                  /offshore_f, offshore_g, onshore, pv_g, pv_c, river, lake, biogas1, biogas2, biogas3, ocgt, ccgt, ccgt-ccs, ngas1, ngas2, ngas3, nuc/
         vre(tec)        'variable tecs'                 /offshore_f, offshore_g, onshore, pv_g, pv_c, river/
         ncomb(tec)      'non-combustible generation'    /offshore_f, offshore_g, onshore, pv_g, pv_c, river, lake, nuc, phs, phs_n, battery1, battery4, hydrogen/
         str(tec)        'storage technologies'          /phs, phs_n, battery1, battery4, methanation1, methanation2, methanation3, hydrogen/
         str_noH2(str)   'storage technologies'          /phs, phs_n, battery1, battery4, methanation1, methanation2, methanation3/
         battery(str)    'battery storage'               /battery1, battery4/
         frr(tec)        'technologies for upward FRR'   /lake, phs, phs_n, ocgt, ccgt, ccgt-ccs, nuc, hydrogen, SC/
         scenCO2         'CO2 tax scenarios'             /1*6/
         costCO2         'CO2 cost items'                /ngas1,ngas2,ngas3,biogas3,methanation3/
         scenH2          'electrolyzer cost scenario'    /1*5/
         P2G(str)                                        /hydrogen, methanation1, methanation2, methanation3/
         type                                            /annuity,fOM/
;
first(h) = ord(h)=1;
last(h) = ord(h)=card(h);
alias(h,hh);
*-------------------------------------------------------------------------------
*                                Inputs
*-------------------------------------------------------------------------------
parameter month(i)  /0*743 1, 744*1439 2, 1440*2183 3, 2184*2903 4
                    2904*3647 5, 3648*4367 6, 4368*5111 7, 5112*5855 8
                    5856*6575 9, 6576*7319 10, 7320*8039 11, 8040*8759 12/
$Offlisting
parameter load_factor(vre,i) 'Production profiles of VRE'
/
$ondelim
$include  inputs/vre_profiles2006new.csv
$offdelim
/;
parameter demand(h) 'demand profile in each hour in GW'
/
$ondelim
$include inputs/demand2050_RTE.csv
$offdelim
/;
Parameter lake_inflows(m) 'monthly lake inflows in GWh'
/
$ondelim
$include  inputs/lake2006.csv
$offdelim
/ ;
parameter epsilon(vre) 'additional FRR requirement for variable renewable energies because of forecast errors'
/
$ondelim
$include  inputs/reserve_requirements_new.csv
$offdelim
/ ;
parameter capa_ex(tec) 'existing capacities of the technologies by December 2017 in GW'
/
$ondelim
$include  inputs/existing_capas_elec_new.csv
$offdelim
/ ;
parameter capa_max(vre) 'maximum capacities of the technologies in GW'
/
$ondelim
$include  inputs/max_capas_elec_new.csv
$offdelim
/ ;
parameter capex(tec) 'annualized power capex cost in M€/GW/year'
/
$ondelim
$include  inputs/annuities_elec_new.csv
$offdelim
/ ;
parameter capex_en(str) 'annualized energy capex cost of storage technologies in M€/GWh/year'
/
$ondelim
$include  inputs/str_annuities_elec_new.csv
$offdelim
/ ;
parameter fOM(tec) 'annualized fixed operation and maintenance costs M€/GW/year'
/
$ondelim
$include  inputs/fO&M_elec_new.csv
$offdelim
/ ;
Parameter vOM(tec) 'Variable operation and maintenance costs in M€/GWh'
/
$ondelim
$include  inputs/vO&M_elec_new.csv
$offdelim
/ ;
parameter costs_scc(scenCO2,costCO2) 'the values of changing parameters'
/
$ondelim
$include inputs/scenariosCO2_new.csv
$offdelim
/ ;
parameter cost_electrolyzer(scenH2,P2G,type) 'electrolyzer cost scenarios'
/
$ondelim
$include inputs/cost_electrolyzer.csv
$offdelim
/ ;
parameter fixed_costs(tec) 'yearly fixed cost of each tec in M€/GW/year' ;
fixed_costs(tec) = capex(tec) + fOM(tec);
parameter s_capex(str) 'charging related annuity of storage in M€/GW/year' /PHS 0, PHS_n 26.66765, battery1 0, battery4 0, methanation1 107.6909, methanation2 107.6909,methanation3 107.6909, hydrogen 51.45598/;
parameter s_opex(str)    'charging related fOM of storage in M€/GW/year'   /PHS 7.5, PHS_n 7.5, battery1 0, battery4 0, methanation1 63, methanation2 63, methanation3 63, hydrogen 21/;
parameter eta_in(str) 'charging efifciency of storage technologies' /PHS 0.9, PHS_n 0.9, battery1 0.9, battery4 0.9, methanation1 0.59, methanation2 0.59,methanation3 0.59, hydrogen 0.8/;
parameter eta_out(str) 'discharging efficiency of storage technolgoies' /PHS 0.9, PHS_n 0.9, battery1 0.95, battery4 0.95, methanation1 0.45, methanation2 0.57,methanation3 0.53, hydrogen 0.40/;
scalar eta_ocgt 'efficiency of OCGT power plants' /0.40/;
scalar eta_ccgt 'efifciency of CCGT power plants with CCS' /0.57/;
scalar eta_ccgt_ccs 'efifciency of CCGT power plants with CCS' /0.53/
scalar cf_nuc 'maximum capacity factor of nuclear power plants' /0.90/;
scalar ramp_rate 'maximum ramp up/down rate for nuclear power plant' /0.5/;
scalar cf_ccgt 'maximum capaity factor of CCGT plant for a year' /0.85/;
scalar max_biogas 'maxium energy can be generated by biogas in TWh' /15/;
scalar load_uncertainty 'uncertainty coefficient for hourly demand' /0.01/;
scalar delta 'load variation factor'     /0.1/;
parameter CO2_tax(scenCO2) 'CO2 tax for each tax scenario' /1 0, 2 100, 3 200, 4 300, 5 400, 6 500/;
parameter vOM0(*) 'variable cost of gas technologies non-regarding the CO2 tax';
vOM0('ngas1')=0.0252;
vOM0('ngas2')=0.0252;
vOM0('ngas3')=0.0252;
vOM0('biogas3')=0.08;
vOM0('methanation3')=0.005444;
parameter capacity_ex(str) 'existing storage capacity in GWh';
parameter H2_demand(h)'hourly hydrogen demand on top of the storage';
H2_demand(h) = 4.56621;
capex('nuc') = 301.799;
capacity_ex('hydrogen') = 3000;
*-------------------------------------------------------------------------------
*                                Model
*-------------------------------------------------------------------------------
variables        GENE(tec,h)     'hourly energy generation in TWh'
                 CAPA(tec)       'overal yearly installed capacity in GW'
                 STORAGE(str,h)  'hourly electricity input of battery storage GW'
                 S(str)          'charging power capacity of each storage technology'
                 STORED(str,h)   'energy stored in each storage technology in GWh'
                 CAPACITY(str)   'energy volume of storage technologies in GWh'
                 RSV(frr,h)      'required upward frequency restoration reserve in GW'
                 COST            'final investment cost in b€'

positive variables GENE(tec,h),CAPA(tec),STORAGE(str,h), S(str),STORED(str,h),CAPACITY(str),RSV(frr,h);

equations        gene_vre        'variables renewable profiles generation'
                 gene_capa       'capacity and genration relation for technologies'
                 batt_cap1
                 batt_cap4
                 combustion1     'the relationship of combustible technologies'
                 combustion2     'the relationship of combustible technologies'
*                 combustion3     'the share of the hydrogen in combustion plants'
*                 max_metha
                 capa_frr        'capacity needed for the secondary reserve requirements'
                 storing         'the definition of stored energy in the storage options'
                 storage_const   'storage in the first hour is equal to the storage in the last hour'
                 storing1         'the definition of stored energy in the storage options - for H2'
                 storage_const1   'storage in the first hour is equal to the storage in the last hour - for H2'
                 battery_capa
                 lake_res        'constraint on water for lake reservoirs'
                 stored_cap      'maximum energy that is stored in storage units'
                 storage_capa1   'the capacity with hourly charging relationship of storage'
                 biogas_const    'maximum energy can be produced by biogas'
*                 nuc_cf          'the yearly capacity factor of nuclear power plants should not pass 80%'
*                 nuc_up          'Nuclear power plant upward flexibility flexibility'
*                 nuc_down        'Nuclear power plant downward flexibility flexibility'
                 ccgt_cf         'the yearly capacity factor of CCGT'
                 reserves        'FRR requirement'
                 adequacy        'supply/demand relation'
                 obj             'the final objective function which is COST';

gene_vre(vre,h)..                GENE(vre,h)             =e=     CAPA(vre)*load_factor(vre,h);
gene_capa(tec,h)..               CAPA(tec)               =g=     GENE(tec,h);
batt_cap1..                      CAPA('battery1')        =e=     CAPACITY('battery1');
batt_cap4..                      CAPA('battery4')        =e=     CAPACITY('battery4')/4;
combustion1(h)..                 GENE('ocgt',h)          =e=     (GENE('methanation1',h) + GENE('biogas1',h) + GENE('ngas1',h))*eta_ocgt;
combustion2(h)..                 GENE('ccgt',h)          =e=     (GENE('methanation2',h) + GENE('biogas2',h) + GENE('ngas2',h))*eta_ccgt;
*combustion3(h)..                 GENE('ccgt-ccs',h)      =e=     (GENE('methanation3',h) + GENE('biogas3',h) + GENE('ngas3',h))*eta_ccgt_ccs;
*max_metha..                      sum(h,GENE('methanation1',h)+GENE('methanation2',h))=l= 27000;
capa_frr(frr,h)..                CAPA(frr)               =g=     GENE(frr,h) + RSV(frr,h);
storing(h,h+1,str_noH2)..        STORED(str_noH2,h+1)         =e=     STORED(str_noH2,h) + STORAGE(str_noH2,h)*eta_in(str_noH2) - GENE(str_noH2,h)/eta_out(str_noH2);
storage_const(str_noH2,first,last)..  STORED(str_noH2,first)       =e=     STORED(str_noH2,last) + STORAGE(str_noH2,last)*eta_in(str_noH2) - GENE(str_noH2,last)/eta_out(str_noH2);
storing1(h,h+1,'hydrogen')..      STORED('hydrogen',h+1)  =e=     STORED('hydrogen',h) + STORAGE('hydrogen',h)*eta_in('hydrogen') - GENE('hydrogen',h)/eta_out('hydrogen')-H2_demand(h);
storage_const1('hydrogen',first,last)..  STORED('hydrogen',first)       =e=     STORED('hydrogen',last) + STORAGE('hydrogen',last)*eta_in('hydrogen') - GENE('hydrogen',last)/eta_out('hydrogen')-H2_demand(last);
lake_res(m)..                    lake_inflows(m)         =g=     sum(h$(month(h) = ord(m)),GENE('lake',h))/1000;
stored_cap(str,h)..              STORED(str,h)           =l=     CAPACITY(str);
storage_capa1(str,h)..           S(str)                  =g=     STORAGE(str,h);
battery_capa(battery)..          S(battery)              =e=     CAPA(battery);
biogas_const..                   sum(h,GENE('biogas1',h)*eta_ocgt+GENE('biogas2',h)*eta_ccgt+GENE('biogas3',h)*eta_ccgt_ccs) =l=     max_biogas*1000;
*nuc_cf..                         sum(h,GENE('nuc',h))    =l=     CAPA('nuc')*cf_nuc*8760;
*nuc_up(h,h+1)..                  GENE('nuc',h+1) + RSV('nuc',h+1) =l= GENE('nuc',h) + ramp_rate*(CAPA('nuc')-GENE('nuc',h))   ;
*nuc_down(h,h+1)..                GENE('nuc',h+1) =g= GENE('nuc',h)*(1 - ramp_rate)   ;
ccgt_cf..                        sum(h,GENE('ccgt',h)) =l=    CAPA('ccgt')*cf_ccgt*8760;
reserves(h)..                    sum(frr, RSV(frr,h))    =e=     sum(vre,epsilon(vre)*CAPA(vre))+ demand(h)*load_uncertainty*(1+delta);
adequacy(h)..                    sum(ncomb,GENE(ncomb,h))+GENE('ocgt',h)+GENE('ccgt',h)+GENE('ccgt-ccs',h)    =g=     demand(h) + sum(str,STORAGE(str,h));
obj..                            COST                    =e=     (sum(tec,(CAPA(tec)-capa_ex(tec))*capex(tec))+ sum(str,(CAPACITY(str)-capacity_ex(str))*capex_en(str))+sum(tec,(CAPA(tec)*fOM(tec)))+ sum(str,S(str)*(s_capex(str)+s_opex(str))) + sum((tec,h),GENE(tec,h)*vOM(tec)))/1000;
*-------------------------------------------------------------------------------
*                                Initial and fixed values
*-------------------------------------------------------------------------------
CAPA.fx('phs') = 4.94;
CAPA.fx('river')= capa_ex('river');
CAPA.fx('lake') = 12.855;
S.fx('phs') = 4.17;
CAPACITY.fx('phs') = 80.16;
CAPA.fx('phs_n') = 4.3;
S.fx('phs_n') = 4.3;
CAPACITY.up('phs_n') = 100;
CAPA.up(vre) = capa_max(vre);
CAPACITY.lo('hydrogen') = capacity_ex('hydrogen');
*CAPACITY.up('hydrogen') = 8000;
CAPA.fx('ccgt-ccs') = 0;
GENE.fx('ccgt-ccs',h) = 0;
CAPA.fx('ngas3') = 0;
GENE.fx('ngas3',h) = 0;
CAPA.fx('biogas3') = 0;
GENE.fx('biogas3',h) = 0;
CAPA.fx('methanation3') = 0;
GENE.fx('methanation3',h) = 0;
CAPA.fx('ngas1') = 0;
GENE.fx('ngas1',h) = 0;
CAPA.fx('ngas2') = 0;
GENE.fx('ngas2',h) = 0;
*-------------------------------------------------------------------------------
*                                Model options
*-------------------------------------------------------------------------------
model EOLES_elec /all/;
*-------------------------------------------------------------------------------
option solvelink=0;
option RESLIM = 1000000;
option lp=CPLEX;
option Savepoint=1;
option solveopt = replace;
option limcol = 0;
option limrow = 0;
option SOLPRINT = OFF;
option solvelink=0;
$onecho > cplex.opt
$offecho
EOLES_elec.optfile=1; EOLES_elec.dictfile=2;
*-------------------------------------------------------------------------------
*                                Solve statement
*-------------------------------------------------------------------------------
$If exist EOLES_elec_p.gdx execute_loadpoint 'EOLES_elec_p';
parameter sumdemand      'the whole demand per year in TWh';
parameter gene_tec(tec) 'Overall yearly energy generated by the technology in TWh';
parameter sumgene        'the whole generation per year in TWh';
parameter sum_FRR 'the whole yearly energy budgeted for reserves in TWh';
parameter reserve(frr) 'capacity allocated for reserve from each FRR tech in GW';
parameter nSTORAGE(str,h);
*Parameter lcoe(gen);
*parameter lcos(str);
parameter lcoe_sys1;
parameter lcoe_sys2;
parameter str_loss 'yearly storage related loss in % of power production';
parameter lc 'load curtailment of the network';
parameter spot_price(h) 'marginal cost'    ;
parameter marginal_cost 'average value over the year of spot price in €/MWh';
parameter CO2_positive 'positive CO2 emission in MtCO2/year';
parameter CO2_negative 'negative CO2 emission in MtCO2/year';
parameter CO2_emission 'the overall CO2 balance in MtCO2/year';
parameter negative_CCS 'yearly CO2 captured by CCS in MtCO2/year';
parameter positive_CCS 'yearly CO2 emitted by CCS in MtCO2/year';
parameter gas_price1(h) ; parameter gas_price2(h) ;
*parameter gas_price3(h) ;
*parameter cf(gen) 'load factor of generation technologies';
parameter technical_cost 'the overall real cost of the system without considering carbon tax or remunerations in b€';
file hourly_generation1 /'outputs/EOLES_elecH2_4500.csv' / ;
file summary1 /'outputs/EOLES_elecH2_4500_summary.csv' / ;
put hourly_generation1;
put 'scenH2','hour'; loop(tec, put tec.tl;) put 'demand', 'ElecStr1','ElecStr4','Pump','Pump_n','hydrogen','CH4_1','CH4_2','CH4_3','elec_market','gas_market1','gas_market2'; put 'OK'/ ;
put summary1;
summary1.pc=5;
summary1.pw=32767;
put 'scenH2','cost'; loop(tec, put tec.tl;) loop(tec,put tec.tl;)put 'LCOE1','LCOE2','spot','str_loss','LC'/;
loop(scenH2,
*vOM('ngas1') = vOM0('ngas1')+ costs_scc(scenCO2,'ngas1')/1000;
*vOM('ngas2') = vOM0('ngas2')+ costs_scc(scenCO2,'ngas2')/1000;
*vOM('ngas3') = vOM0('ngas3')+ costs_scc(scenCO2,'ngas3')/1000;
*vOM('biogas3') = vOM0('biogas3')+costs_scc(scenCO2,'biogas3')/1000;
*vOM('methanation3') = vOM0('methanation3')+costs_scc(scenCO2,'methanation3')/1000;
s_capex(P2G) = cost_electrolyzer(scenH2,P2G,'annuity');
s_opex(P2G) = cost_electrolyzer(scenH2,P2G,'fOM');
Solve EOLES_elec using lp minimizing COST;
sumdemand =  sum(h,demand(h))/1000;
gene_tec(tec) = sum(h,GENE.l(tec,h))/1000;
sumgene = sum((ncomb,h),GENE.l(ncomb,h))/1000 + gene_tec('ocgt')+ gene_tec('ccgt')+ gene_tec('ccgt-ccs');
sum_FRR = sum((h,frr),RSV.l(frr,h))/1000;
reserve(frr) = smax(h,RSV.l(frr,h));
nSTORAGE(str,h) = 0 - STORAGE.l(str,h);
*lcoe(gen) = (CAPA.l(gen)*(fOM(gen)+capex(gen))+ gene_tec(gen)*vOM(gen)*1000)/gene_tec(gen);
*lcos(str) = (CAPA.l(str)*(fOM(str)+capex(str))+ gene_tec(str)*vOM(str)*1000 + S.l(str)*(s_capex(str)+s_opex(str))+ CAPACITY.l(str)*capex_en(str))/gene_tec(str);
lcoe_sys1 = cost.l*1000/sumgene;
lcoe_sys2 = cost.l*1000/sumdemand;
*cf(gen) = gene_tec(gen)*1000/(8760*CAPA.l(gen));
str_loss = (sum((str,h),STORAGE.l(str,h))-sum(str,gene_tec(str)*1000))/(sumgene*10);
lc = ((sumgene - sumdemand)*100/sumgene) - str_loss;
spot_price(h) = 1000000*adequacy.m(h);
gas_price1(h) = -1000000*combustion1.m(h);
gas_price2(h) = -1000000*combustion2.m(h);
*gas_price3(h) = -1000000*combustion3.m(h);
marginal_cost = sum(h,spot_price(h))/8760;
*CO2_positive = (sum(h,GENE.l('ngas3',h)*0.53*40+(GENE.l('ngas1',h)*0.4+GENE.l('ngas2',h)*0.57)*320))/1000000;
*CO2_negative = sum(h,(GENE.l('biogas3',h)+GENE.l('methanation3',h))*0.53)*320/1000000;
*CO2_emission = CO2_positive - CO2_negative;
*technical_cost = COST.l - (CO2_positive - CO2_negative)*CO2_tax(scenCO2)/1000;
*-------------------------------------------------------------------------------
*                                Display statement
*-------------------------------------------------------------------------------
display cost.l;
display capa.l;
display gene_tec;
display sumdemand; display sumgene;
display lcoe_sys1; display lcoe_sys2;
*display lcoe; display lcos;
*display CO2_positive; display CO2_negative; display CO2_emission;
display CAPACITY.l;
*display cf;
display lc; display str_loss; display marginal_cost;
*display technical_cost;
*-------------------------------------------------------------------------------
*                                Output
*-------------------------------------------------------------------------------
put summary1;
summary1.pc=5;
put scenH2.tl,COST.l, loop(tec, put CAPA.l(tec);) loop(tec,put gene_tec(tec);)put lcoe_sys1,lcoe_sys2,marginal_cost,str_loss,LC /;
put hourly_generation1;
hourly_generation1.pc=5;
loop (h,
put scenH2.tl, put h.tl; loop(tec, put GENE.l(tec,h);) put demand(h); put nSTORAGE('battery1',h),nSTORAGE('battery4',h), nSTORAGE('PHS',h),nSTORAGE('PHS_N',h),nSTORAGE('hydrogen',h),nSTORAGE('methanation1',h),nSTORAGE('methanation2',h),nSTORAGE('methanation3',h),spot_price(h),gas_price1(h),gas_price2(h); put 'OK'/
;);
);
*-------------------------------------------------------------------------------
*                                The End :D
*-------------------------------------------------------------------------------
