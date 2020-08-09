:class lBoxPage : MiPage
    :field public _Sessioned←1

    :field public prj←''

    ∇ {r}←Wrap
      :Access Public
      OnLoad,←'jBoxTooltip=new jBox("Tooltip",{theme: "TooltipDark",id:"jBoxTooltip",getTitle: "data-jbox-title", getContent: "data-jbox-content",attach: "[data-jbox-content]",reload:"strict"}).attach();'
      Use'⍎/assets/lBox.js'
      Use'⍕/jBox/themes/TooltipDark.css'
      Use'jBox'
      Use'Bootstrap4'
      Use'⍕/assets/style.css'
      'class'Body.Set'bg-dark text-white'
     
      'style'Body.Set'padding-top: 4em;' ⍝ for sticky nav! (was 55pc, but I guess em will be more responsive)

      nav←'#topnav .navbar .navbar-expand-md .navbar-dark .bg-dark .align-items-stretch .w-100 .fixed-top .py-0'Add _.nav
      (nav.Add _.span'LeitnerBox' '.navbar-text .navbar-flex .tstext #tsTitle').On'click' 'Go'
      btn←'.navbar-toggler type=button data-toggle=collapse data-target="#m1nv"'nav.Add _.button
      '.navbar-toggler-icon'btn.Add _.span
      ul←'.navbar-nav #men1'('.collapse .navbar-collapse #m1nv'nav.Add _.div).Add _.ul
      ⍝     ⍝ul←'.navbar-nav #men1'nav.Add _.ul
      ⍝     r←'.nav-item .dropdown #ddTopLeft 'ul.Add _.li
      ⍝     '.nav-link .dropdown-toggle data-toggle=dropdown href=# .pt-0 .pb-0 #ddTitle'r.Add _.a'Dataset'
      ⍝     '#ddMenu .dropdown-menu aria-labelledby=ddTopLeft'r.Add _.div
      ⍝     h←nav.Add _.Handler'#ddMenu' 'click' 'Handle_ddSelect'
      ⍝     '.navbar-nav #men2 .ml-auto .mt-auto .pb-2'nav.Add _.ul
     
      ll←'File'{r←('.nav-item .dropdown')ul.Insert _.li ⋄ nul←'.nav-link .pt-0 .dropdown-toggle data-toggle=dropdown id=men-file role=button aria-haspopup=true aria-expanded=false'r.Add _.a ⍺('href=#') ⋄ r}''
      dd←'.dropdown-menu .dropdown-menu aria-labelledby=men-file'll.Add _.div
     
      :If {6::0 ⋄ 'HRServer'≡⍎⍵}'#.Boot.ms.Framework' ⍝ if we're running with DUI
          '.dropdown-divider'dd.Add _.div
          (dd.Add _.a'Exit' '.dropdown-item onclick=off()').On'click' 'OFF'
      :EndIf
     
     
      ll←'Data'{r←('.nav-item .dropdown')ul.Add _.li ⋄ nul←'.nav-link .pt-0 .dropdown-toggle data-toggle=dropdown id=men-data role=button aria-haspopup=true aria-expanded=false'r.Add _.a ⍺('href=#') ⋄ r}''
      dd←'.dropdown-menu .dropdown-menu aria-labelledby=men-data'll.Add _.div
      '#index'dd.Add _.a'Session' '.dropdown-item href=/index'
      '#Select'dd.Add _.a'Select' '.dropdown-item href=/Select'
     
     
      ll←'Help'{r←('.nav-item .dropdown')ul.Add _.li ⋄ nul←'.nav-link .pt-0  .pb-0 .dropdown-toggle data-toggle=dropdown id=helpmenu role=button aria-haspopup=true aria-expanded=false'r.Add _.a ⍺('href=#') ⋄ r}''
      dd←('.dropdown-menu aria-labelledby=helpmenu')ll.Add _.div
     
      :If 0<≢2 ⎕NQ'.' 'GetEnvironment' 'TamStat_DEV'  ⍝ "secret" flag to recognize MB's environment ;)
      :AndIf {0::0 ⋄ 0<≢⍵._Renderer.⎕NL-⍳9}#.Boot.ms
          ('#ShowDevToola'dd.Add _.a'Show DevTools' '.dropdown-item onlick="return false;"').On'click' 'ShowDevTools'
      :EndIf
      :If ⎕NEXISTS #.Boot.AppRoot,1↓fl←'/assets/',(2⊃⎕NPARTS _Request.Page),'.help.js'
          Add _.Script''fl
          '#tsHelp'dd.Add _.a'Feature-Help' '.dropdown-item href=# onclick=tsHelp();'
      :EndIf
      :If {0::1 ⋄ 0=≢⍵._Renderer.⎕NL-⍳9}#.Boot.ms  ⍝ only offer web-link if opened in browser - currently do not have methods in DUI to deal with multiple renderers...
          '#website'dd.Add _.a'Website' '.dropdown-item href=https://github.com/mbaas2/FRAPL-LeitnerBox target=_new rel=noopener'
      :EndIf
      '#about_ts'dd.Add _.a'About LeitnerBox' '.dropdown-item href=# onclick=$("#about").modal("show");'
     
    ⍝ call the base class Wrap function
      r←⎕BASE.Wrap
     
    ∇

    ∇ R←ShowDevTools
      :Access public
      #.Boot.ms._Renderer.ShowDevTools 1
      R←''
    ∇


:endclass
