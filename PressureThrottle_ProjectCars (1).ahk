; ============================================================
;  PRESSURE THROTTLE & BRAKE — Project Cars 1
;  W = Throttle (pressure ramp)
;  B = Brake    (pressure ramp)
;
;  REQUIRES: AutoHotkey v2  (https://www.autohotkey.com/)
;  INSTALL:  Right-click this file → Run with AutoHotkey
; ============================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir

; ─── CAR MODE — uncomment ONE block only ───────────────────

; ── NORMAL / NA CARS (hatchbacks, GT3, road cars)
; RAMP_STEPS    := 20
; RAMP_INTERVAL := 75
; MIN_PULSE     := 8
; MAX_PULSE     := 60
; CYCLE_LENGTH  := 60

; ── TURBO / SUPERCAR (reduce torque spike, smoother ramp)
RAMP_STEPS    := 30        ; more steps = finer control
RAMP_INTERVAL := 90        ; slower build-up between steps
MIN_PULSE     := 5         ; very light initial blip
MAX_PULSE     := 42        ; cap max duty cycle (~70% of normal)
CYCLE_LENGTH  := 60

; ── FORMULA / HIGH DOWNFORCE (ultra-precise, no snap)
; RAMP_STEPS    := 40
; RAMP_INTERVAL := 100
; MIN_PULSE     := 4
; MAX_PULSE     := 35
; CYCLE_LENGTH  := 60

; ───────────────────────────────────────────────────────────

; Internal state
global wActive := false
global bActive := false
global wStep   := 0
global bStep   := 0

; ─── THROTTLE (W key) ──────────────────────────────────────
*w::
{
    global wActive, wStep
    if wActive
        return
    wActive := true
    wStep   := 0
    SetTimer ThrottleRamp, RAMP_INTERVAL
    ThrottlePulse()
}

*w up::
{
    global wActive, wStep
    wActive := false
    wStep   := 0
    SetTimer ThrottleRamp, 0
    Send "{w up}"
}

ThrottleRamp()
{
    global wStep, RAMP_STEPS
    if wStep < RAMP_STEPS
        wStep++
}

ThrottlePulse()
{
    global wActive, wStep, RAMP_STEPS, MIN_PULSE, MAX_PULSE, CYCLE_LENGTH
    if !wActive
        return

    pressure := wStep / RAMP_STEPS
    onTime   := MIN_PULSE + Round(pressure * (MAX_PULSE - MIN_PULSE))
    offTime  := CYCLE_LENGTH - onTime

    if pressure >= 1.0 {
        Send "{w down}"
        SetTimer ThrottlePulse, CYCLE_LENGTH
    } else {
        Send "{w down}"
        Sleep onTime
        Send "{w up}"
        SetTimer ThrottlePulse, offTime
    }
}

; ─── BRAKE (B key) ─────────────────────────────────────────
*b::
{
    global bActive, bStep
    if bActive
        return
    bActive := true
    bStep   := 0
    SetTimer BrakeRamp, RAMP_INTERVAL
    BrakePulse()
}

*b up::
{
    global bActive, bStep
    bActive := false
    bStep   := 0
    SetTimer BrakeRamp, 0
    Send "{b up}"
}

BrakeRamp()
{
    global bStep, RAMP_STEPS
    if bStep < RAMP_STEPS
        bStep++
}

BrakePulse()
{
    global bActive, bStep, RAMP_STEPS, MIN_PULSE, MAX_PULSE, CYCLE_LENGTH
    if !bActive
        return

    pressure := bStep / RAMP_STEPS
    onTime   := MIN_PULSE + Round(pressure * (MAX_PULSE - MIN_PULSE))
    offTime  := CYCLE_LENGTH - onTime

    if pressure >= 1.0 {
        Send "{b down}"
        SetTimer BrakePulse, CYCLE_LENGTH
    } else {
        Send "{b down}"
        Sleep onTime
        Send "{b up}"
        SetTimer BrakePulse, offTime
    }
}

; ─── TRAY MENU ─────────────────────────────────────────────
TraySetIcon "*"
A_TrayMenu.Delete()
A_TrayMenu.Add("Pressure Throttle — W/B Active", (*) => 0)
A_TrayMenu.Disable("Pressure Throttle — W/B Active")
A_TrayMenu.Add()
A_TrayMenu.Add("Exit", (*) => ExitApp())
