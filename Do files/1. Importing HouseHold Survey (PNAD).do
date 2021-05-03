		  
											*IMPORTING BRAZILIAN HOUSEHOLD SURVEY (PNAD)*
	*________________________________________________________________________________________________________________________________*


	*INTRUCTIONS TO USE DATAZOOM TOOL TO IMPORT THE PESQUISA NACIONAL POR AMOSTRA DE DOMICÍLIOS
	*-------------------------------------------------------------------------------------------------------------------------------*
	/*
	1 - Run:
	net from http://www.econ.puc-rio.br/datazoom/portugues  
	net install datazoom_pnad

	2 - Save PNAD microdata (in txt format). For example: "C:\Vivian\PNAD\2014", "C:\Vivian\PNAD\2008". 
	DO NOT USE FOLDER's NAMES WITH SPACES

	4 - Check if the name of the files (in txt format) are the same as especified in DataZoom: help datazoom_pnad

	5 - Run the code bellow. 
	*/
	*________________________________________________________________________________________________________________________________*



	*2007-2014
	*-------------------------------------------------------------------------------------------------------------------------------*
	datazoom_pnad, years(2014 2013 2012 2011 2009 2008 2007)  		///
	original("$raw/2014/PES2014.txt" "$raw/2014/DOM2014.txt"  		///
			 "$raw/2013/PES2013.txt" "$raw/2013/DOM2013.txt"  		///
			 "$raw/2012/PES2012.txt" "$raw/2012/DOM2012.txt"  		///
			 "$raw/2011/PES2011.txt" "$raw/2011/DOM2011.txt"  		///
			 "$raw/2009/PES2009.txt" "$raw/2009/DOM2009.txt"  		///
			 "$raw/2008/PES2008.txt" "$raw/2008/DOM2008.txt"  		///
			 "$raw/2007/PES2007.txt" "$raw/2007/DOM2007.txt"	) 	///
			 saving("$inter") both ncomp 
	*-------------------------------------------------------------------------------------------------------------------------------*


	*2002-2006
	*-------------------------------------------------------------------------------------------------------------------------------*
	datazoom_pnad, years(2006 2005 2004 2003 2002				)  	///
	original("$raw/2006/PES2006.txt" "$raw/2006/DOM2006.txt"  		///
			 "$raw/2005/PES2005.txt" "$raw/2005/DOM2005.txt"  		///
			 "$raw/2004/PES2004.txt" "$raw/2004/DOM2004.txt"  		///
			 "$raw/2003/PES2003.txt" "$raw/2003/DOM2003.txt"  		///
			 "$raw/2002/PES2002.txt" "$raw/2002/DOM2002.txt"  	) 	///
			 saving("$inter") both ncomp 
	*-------------------------------------------------------------------------------------------------------------------------------*


	*1998-2001
	*-------------------------------------------------------------------------------------------------------------------------------*
	datazoom_pnad, years(2001 1999 1998)  							///
	original("$raw/2001/PES2001.txt"  "$raw/2001/DOM2001.txt" 		///
			 "$raw/1999/Pessoa99.txt" "$raw/1999/Domicilio99.txt"   ///
			 "$raw/1998/Pessoa98.txt" "$raw/1998/Domicilio98.txt")  ///
			 saving("$inter") both ncomp 
	*-------------------------------------------------------------------------------------------------------------------------------*


	*ISO-8859-1 (Para aceitar carácteres especiais)
	*-------------------------------------------------------------------------------------------------------------------------------*
	clear
	unicode encoding set ISO-8859-1
	foreach year in in 1998 1999 2001 2002 2003 2004 2005 2006 2007 2008 2009 2011 2012 2013 2014 2015 {
		cd "$inter"
		unicode translate *.dta
	}
	*-------------------------------------------------------------------------------------------------------------------------------*


	*2015* Nao conseguimos importar usando o DataZoom
	*-------------------------------------------------------------------------------------------------------------------------------*
	clear 
	set more off
	#delimit
	infix
	str V0101 1-4
	str UF 5-6
	str V0102 5-12
	str V0103 13-15
	str V0104 16-17
	str V0105 18-19
	str V0106 20-21
	str V0201 22-22
	str V0202 23-23
	str V0203 24-24
	str V0204 25-25
	str V0205 26-27
	str V0206 28-29
	str V0207 30-30
	str V0208 31-42
	str V0209 43-54
	str V0210 55-55
	str V0211 56-56
	str V0212 57-57
	str V0213 58-58
	str V0214 59-59
	str V0215 60-60
	str V0216 61-61
	str V2016 62-63
	str V0217 64-64
	str V0218 65-65
	str V0219 66-66
	str V0220 67-67
	str V2020 68-68
	str V0221 69-69
	str V0222 70-70
	str V0223 71-71
	str V0224 72-72
	str V0225 73-73
	str V0226 74-74
	str V0227 75-75
	str V2027 76-76
	str V0228 77-77
	str V0229 78-78
	str V0230 79-79
	str V0231 80-80
	str V0232 81-81
	str V2032 82-82
	str V4105 83-83
	str V4107 84-84
	str V4600 85-86
	str V4601 87-88
	str V4602 89-92
	str V4604 93-94
	str V4605 95-106
	str V4606 107-109
	str V4607 110-121
	str V4608 122-127
	str V4609 128-136
	str V4610 137-139
	str V4611 140-144
	str V4614 145-156
	str UPA 157-160
	str V4617 161-167
	str V4618 168-174
	str V4620 175-176
	str V4621 177-188
	str V4622 189-190
	str V4624 191-191
	str V9992 192-199
	using "$raw/2015/DOM2015.txt";
	sort UF V0102 V0103;
	save "$inter/pnad2015_domicílios.dta", replace;
	clear; 
	infix

	str V0101 1-4
	str UF 5-6
	str V0102 5-12
	str V0103 13-15
	str V0301 16-17
	str V0302 18-18
	str V3031 19-20
	str V3032 21-22
	str V3033 23-26
	str V8005 27-29
	str V0401 30-30
	str V0402 31-31
	str V0403 32-32
	str V0404 33-33
	str V0405 34-34
	str V0406 35-35
	str V0407 36-37
	str V0408 38-38
	str V4111 39-39
	str V4112 40-40
	str V4011 41-41
	str V0412 42-42
	str V0501 43-43
	str V0502 44-44
	str V5030 45-46
	str V0504 47-47
	str V0505 48-48
	str V5061 49-49
	str V5062 50-50
	str V5063 51-51
	str V5064 52-52
	str V5065 53-53
	str V0507 54-54
	str V5080 55-56
	str V5090 57-58
	str V0510 59-59
	str V0511 60-60
	str V5121 61-61
	str V5122 62-62
	str V5123 63-63
	str V5124 64-64
	str V5125 65-65
	str V5126 66-66
	str V0601 67-67
	str V0602 68-68
	str V6002 69-69
	str V6020 70-70
	str V6003 71-72
	str V6030 73-73
	str V0604 74-74
	str V0605 75-75
	str V0606 76-76
	str V6007 77-78
	str V6070 79-79
	str V0608 80-80
	str V0609 81-81
	str V0610 82-82
	str V0611 83-83
	str V06111 84-84
	str V061111 85-85
	str V06112 86-86
	str V0612 87-87
	str V0701 88-88
	str V0702 89-89
	str V0703 90-90
	str V0704 91-91
	str V0705 92-92
	str V7060 93-96
	str V7070 97-101
	str V0708 102-102
	str V7090 103-106
	str V7100 107-111
	str V0711 112-112
	str V7121 113-113
	str V7122 114-125
	str V7124 126-126
	str V7125 127-138
	str V7127 139-139
	str V7128 140-140
	str V0713 141-142
	str V0714 143-143
	str V0715 144-145
	str V0716 146-146
	str V9001 147-147
	str V9002 148-148
	str V9003 149-149
	str V9004 150-150
	str V9005 151-151
	str V9906 152-155
	str V9907 156-160
	str V9008 161-162
	str V9009 163-163
	str V9010 164-164
	str V9011 165-165
	str V9012 166-166
	str V9013 167-167
	str V9014 168-168
	str V9151 169-169
	str V9152 170-180
	str V9154 181-187
	str V9156 188-188
	str V9157 189-199
	str V9159 200-206
	str V9161 207-207
	str V9162 208-218
	str V9164 219-225
	str V9016 226-226
	str V9017 227-227
	str V9018 228-228
	str V9019 229-229
	str V9201 230-230
	str V9202 231-241
	str V9204 242-248
	str V9206 249-249
	str V9207 250-260
	str V9209 261-267
	str V9211 268-268
	str V9212 269-279
	str V9214 280-286
	str V9021 287-287
	str V9022 288-288
	str V9023 289-289
	str V9024 290-290
	str V9025 291-291
	str V9026 292-292
	str V9027 293-293
	str V9028 294-294
	str V9029 295-295
	str V9030 296-296
	str V9031 297-297
	str V9032 298-298
	str V9033 299-299
	str V9034 300-300
	str V9035 301-301
	str V9036 302-302
	str V9037 303-303
	str V9038 304-304
	str V9039 305-305
	str V9040 306-306
	str V9041 307-307
	str V9042 308-308
	str V9043 309-309
	str V9044 310-310
	str V9045 311-311
	str V9046 312-312
	str V9047 313-313
	str V9048 314-314
	str V9049 315-315
	str V9050 316-316
	str V9051 317-317
	str V9052 318-318
	str V9531 319-319
	str V9532 320-331
	str V9534 332-332
	str V9535 333-344
	str V9537 345-345
	str V90531 346-346
	str V90532 347-347
	str V90533 348-348
	str V9054 349-349
	str V9055 350-350
	str V9056 351-351
	str V9057 352-352
	str V9058 353-354
	str V9059 355-355
	str V9060 356-356
	str V9611 357-358
	str V9612 359-360
	str V9062 361-361
	str V9063 362-362
	str V9064 363-364
	str V9065 365-365
	str V9066 366-366
	str V9067 367-367
	str V9068 368-368
	str V9069 369-369
	str V9070 370-370
	str V9971 371-374
	str V9972 375-379
	str V9073 380-381
	str V9074 382-382
	str V9075 383-383
	str V9076 384-384
	str V9077 385-385
	str V9078 386-386
	str V9079 387-387
	str V9080 388-388
	str V9081 389-389
	str V9082 390-390
	str V9083 391-391
	str V9084 392-392
	str V9085 393-393
	str V9861 394-395
	str V9862 396-397
	str V9087 398-398
	str V9088 399-399
	str V9891 400-400
	str V9892 401-402
	str V9990 403-406
	str V9991 407-411
	str V9092 412-412
	str V9093 413-413
	str V9094 414-414
	str V9095 415-415
	str V9096 416-416
	str V9097 417-417
	str V9981 418-418
	str V9982 419-430
	str V9984 431-431
	str V9985 432-443
	str V9987 444-444
	str V9099 445-445
	str V9100 446-446
	str V9101 447-448
	str V1021 449-449
	str V1022 450-461
	str V1024 462-462
	str V1025 463-474
	str V1027 475-475
	str V1028 476-476
	str V9103 477-477
	str V9104 478-478
	str V9105 479-480
	str V9106 481-481
	str V9107 482-482
	str V9108 483-483
	str V1091 484-485
	str V1092 486-487
	str V9910 488-491
	str V9911 492-496
	str V9112 497-497
	str V9113 498-498
	str V9114 499-499
	str V9115 500-500
	str V9116 501-501
	str V9117 502-502
	str V9118 503-503
	str V9119 504-504
	str V9120 505-505
	str V9121 506-506
	str V9921 507-508
	str V9122 509-509
	str V9123 510-510
	str V9124 511-511
	str V1251 512-513
	str V1252 514-525
	str V1254 526-527
	str V1255 528-539
	str V1257 540-541
	str V1258 542-553
	str V1260 554-555
	str V1261 556-567
	str V1263 568-569
	str V1264 570-581
	str V1266 582-583
	str V1267 584-595
	str V1269 596-597
	str V1270 598-609
	str V1272 610-611
	str V1273 612-623
	str V9126 624-624
	str V1101 625-625
	str V1141 626-627
	str V1142 628-629
	str V1151 630-631
	str V1152 632-633
	str V1153 634-634
	str V1154 635-635
	str V1161 636-637
	str V1162 638-639
	str V1163 640-640
	str V1164 641-641
	str V1107 642-642
	str V1181 643-644
	str V1182 645-648
	str V1109 649-649
	str V1110 650-650
	str V1111 651-652
	str V1112 653-654
	str V1113 655-655
	str V1114 656-656
	str V1115 657-657
	str V4801 658-659
	str V4802 660-661
	str V4803 662-663
	str V4704 664-664
	str V4805 665-665
	str V4706 666-667
	str V4707 668-668
	str V4808 669-669
	str V4809 670-671
	str V4810 672-673
	str V4711 674-674
	str V4812 675-675
	str V4713 676-676
	str V4814 677-677
	str V4715 678-679
	str V4816 680-681
	str V4817 682-683
	str V4718 684-695
	str V4719 696-707
	str V4720 708-719
	str V4721 720-731
	str V4722 732-743
	str V4723 744-745
	str V4724 746-747
	str V4727 748-748
	str V4728 749-749
	str V4729 750-754
	str V4732 755-759
	str V4735 760-760
	str V4838 761-761
	str V6502 762-762
	str V4741 763-764
	str V4742 765-776
	str V4743 777-778
	str V4745 779-779
	str V4746 780-780
	str V4747 781-781
	str V4748 782-782
	str V4749 783-783
	str V4750 784-795
	str V9993 796-803
	using "$raw/2015/PES2015.txt";
	sort UF V0102 V0103;
	save "$inter/pnad2015_pessoas.dta", replace;
	clear;  

	#delimit cr

	use "$inter/pnad2015_pessoas.dta", clear
		merge m:1 UF V0102 V0103 using "$inter/pnad2015_domicílios.dta", keep (match master) nogen
		destring *, replace
		erase "$inter/pnad2015_pessoas.dta"
		erase "$inter/pnad2015_domicílios.dta"
		rename *, lower
	save "$inter/pnad2015.dta", replace



