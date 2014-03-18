:: identify of current user account
  if /i %username% EQU sr01200 (
    set from=achirkov@samara.dosmartec.ru
    set ws=ws-47
    set name=Alexey Chirkov
    set sign=Alexey Chirkov : Smartec, Samara : tel. +7 846 303-03-43 +124 : fax +7 846 303-33-58
    goto :welcome
    )
    
  if /i %username% EQU sr01006 (
    set from=ashunin@samara.dosmartec.ru
    set ws=ws-46
    set name=Andrey Shunin
    set sign=Andrey Shunin : Smartec, Samara : tel. +7 846 303-03-43 +110 : fax +7 846 303-33-58
    goto :welcome
    )

  if /i %username% EQU sr01103 (
    set from=idemin@samara.dosmartec.ru
    set ws=ws-3
    set name=Ivan Demin
    set sign=Ivan Demin : S_CT : +7 846 303-03-43 ext.115 : Smartec
    goto :welcome
    )
    
  if /i %username% EQU sr01201 (
    set from=%supmail%
    set ws=ws-3
    set name=Ivan Rabkesov
    set sign=Ivan Rabkesov : S_CT : +7 846 303-03-43 ext.115 : Smartec
    goto :welcome
    )

  if /i %username% EQU sr01107 (
    set from=druzanova@samara.dosmartec.ru
    set tom=druzanova@samara.dosmartec.ru
    set ws=ws-54
    set name=Darya Ruzanova
    set sign=Darya Ruzanova : Design : +7 846 303-03-43 ext.115 : Smartec
    goto :welcome
    )
    
  if /i %username% EQU sr01062 (
    set from=flallinec@samara.dosmartec.ru
    set tom=flallinec@samara.dosmartec.ru
    set ws=ws-11
    set name=Francois Lallinec
    set sign=Francois Lallinec : S_CT : +7 846 303-03-43 ext.115 : Smartec
    goto :welcome
    )
    
  if /i %username% EQU sr00201 (
    set from=aanikeev@dosmartec.ru
    set name=Anatoly Anikeev
    set sign=Anatoly Anikeev : M_CT1 : +7 495 937-62-90 ext.342 : Smartec
    goto :welcome
    )
    
  if /i %username% EQU sr00204 (
    set from=agubsky@dosmartec.ru
    set name=Andrey Gubsky
    set sign=Andrey Goubski : "Smartec" JSC : tel. 7-495 937-62-90 +334 : fax 7-495 937-62-93
    goto :welcome
    ) else (
      if not exist config.txt set name=Engineer
      )

