# Lumen design system — Radiance

Award-bar, clinical-calm — not wellness pastel, not Dovetail cream/terracotta.
Atmosphere: **dawn light**, photography, icon wells — editorial calm over checklist chrome.

## Tokens

| Token | Hex | Use |
|-------|-----|-----|
| canvas | `#ECF2F0` | Soft sage paper (cards read as white on it) |
| surface | `#FFFFFF` | Cards |
| mist | `#E1EBE9` | Soft teal wash / image wells |
| ink | `#1A1F24` | Primary text |
| inkSoft | `#5A646C` | Secondary |
| muted | `#8C949A` | Captions |
| teal | `#0B4F54` | Pillar accent / links / CTAs |
| tealDeep | `#073A3E` | Compact vitals |
| tealSoft | `#D6E8E9` | Selected rows / wells |
| gold | `#C4A35A` | Agency / rare emphasis |
| goldSoft | `#F4EAD2` | Soft prompts |
| sage | `#3D6B5A` | Kept / success |
| sageSoft | `#DCE8E0` | Kept rows |

## Typography

- Display / greetings: **serif** ~28 (one expressive face per screen)
- Section labels: 12–13 semibold caps-feel
- Task titles: 15–16 semibold sans
- Body: 15–17 SF

## Jobs → tabs

| Tab | Job | Owns |
|-----|-----|------|
| **Today** | Orient + act | Greeting, one next action, today’s checklist, capture (+), notes, coach |
| **Progress** | Understand over time | Kept-days, 7-day trends, weekly check-in, promise history |
| **Learn** | Learn | Curriculum + coaches |
| **Circle** | Connect | Forums |
| **Plan** | Steer | Conditions + HealthKit / Fitbit |

## Today composition

1. Header — greeting + plan (Orient).
2. **One next action** — Care insight for the active focus.
3. **Today’s focus** — daily goals only (no week rings).
4. **Latest** — compact vitals chips + link to Progress.
5. Notes + coach + optional lesson / manual glucose.
6. **Log FAB (+)** — note / gated glucose / weight / sync.

## Progress composition

1. Kept-days strip + soft streak caption.
2. Plan-gated trend cards (steps always; glucose / BP / weight by conditions).
3. This week’s promises + weekly check-in.

## Streak tone

Real streaks and week rings on **Progress only**, kind copy. Missed days soft — never fire icons or guilt.

## Composition rules

1. One job per tab — Today never owns trends; Progress never owns daily capture.
2. **Care-plan gating** — vitals, glucose, weight, commitments, trends follow Plan conditions. Glucose only for Type 2 or prediabetes (not GLP-1 alone).
3. Primary CTAs use solid teal — not system blue glass.
4. Empty / permission / disclaimer states are designed copy, not red errors.
5. Photography and SF Symbol wells are first-class.

## Motion (host)

Keep TEA declarative. Prefer sheet present + ring/step count updates over decorative animation in v1.
