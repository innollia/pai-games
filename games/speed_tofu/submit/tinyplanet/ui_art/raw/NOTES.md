# v002 generation notes

Generated sequentially with built-in imagegen: save prompt, submit it verbatim for exactly one image, review, copy the selected original PNG. Twelve image calls produced eleven selected PNGs. No cropping, resizing, image editing, game code, git, or v001 changes.

All eleven messages share the same meta prompt, ANTI-SLOP and v002 style card. All saved prompts preserve the complete ANTI-SLOP block (verified after newline normalization). Requested background objects and empty upper sky take precedence over generic composition limits. Requested X/check pictograms are retained.

| Selected file | Requested ratio | Original pixels | Result |
| --- | --- | --- | --- |
| title_bg.png | 9:16 | 941 x 1672 | Approximate ratio; faceted planets and mailbox, vertical eyes, two legs, windmill, moon and two clouds; empty upper sky. |
| title_plate.png | 3:1 | 2172 x 724 | Matches; blank cream banner and V-notched ends. |
| start_button.png | 4:1 | 1983 x 793 | FAILED ratio: approximately 2.50:1. Polygonal yellow key and darker bottom lip retained unchanged. |
| panel.png | 1:1 | 1254 x 1254 | Regenerated once; second result retained for stronger angular edge facets. Blank center. |
| icon_list.png | 1:1 | 1254 x 1254 | Three checks and three blank rules; no writing. |
| icon_close.png | 1:1 | 1254 x 1254 | Faceted coral button and navy X. |
| icon_parcel.png | 1:1 | 1254 x 1254 | Brown faceted parcel and cream crossed string. |
| icon_flower.png | 1:1 | 1254 x 1254 | Mint faceted flower and short stem. |
| icon_dome.png | 1:1 | 1254 x 1254 | Blue faceted bell dome and white rim; no glossy streaks. |
| icon_wind.png | 1:1 | 1254 x 1254 | Four blades, one hub, two angular wind swirls. |
| icon_sunset.png | 1:1 | 1254 x 1254 | Half-set faceted orange sun and coral/yellow striped band. |

Panel regeneration used the identical saved prompt because its first result lacked visible facet treatment. Second result has clearer edge facets and was kept. All other images use their first generation.

Visual review: polygonal silhouettes and broad facets; no unwanted writing or obvious specular streaks observed. Isolated backgrounds appear white. Subtle tonal variation persists within some nominally flat fields, so mathematically uniform per-facet colors are not certified. Panel facets concentrate at the edges around its blank center.

Failure: start_button does not meet the 4:1 canvas requirement. The tool exposes no explicit size/aspect parameter; 4:1 was included in the verbatim prompt. Original retained without cropping or resizing.
