# Happy eye animation

The original `HappyAvatar` image is restored with its original pose, fur, face and smile. The eyes blink while the original image gently floats and sways. Tapping restores the original hop and sparkle reaction. Local lids blink every 5.3 seconds and on tap, with matching rendering in SwiftUI and the browser. The image artwork is unchanged; there is no articulated body movement.

Pause freezes the eye animation along with the scenery. Reduce Motion keeps the eyes in their original state. Selection, Next, and the animated meadow remain in place.

The previous rig atlas below is retained as unused artwork and provenance; it is no longer rendered.

## Asset and prompt

Generated using the built-in imagegen tool. Reference: the original Happy avatar, generated from the user's screenshot. Asset: `MoodDay/Assets.xcassets/HappyRig.imageset/happy-rig.png` (1254 × 1254 with alpha transparency). The old avatar remains as a fallback.

### Final generation prompt

Use case: identity-preserve. Asset type: a production character animation parts atlas, transparent PNG, square image, exactly 2 columns and 2 rows of equally sized cells. Reference image is Happy, the fluffy ivory robot plush. Preserve its exquisite realistic soft ivory fur, black glass oval screen, grey knitted paws, original friendly proportions and warm soft lighting. Render FOUR DETACHED CHARACTER PARTS, one part centered inside each quadrant with 12% clear margin around it. Top left quadrant: ONLY Happy's large round ivory furry HEAD, straight upright front view, no tilt, complete circular furry hood surrounding a BLANK smooth BLACK oval face screen. IMPORTANT completely blank black screen, no eyes, no mouth, no expression; facial features will be animated in code. No neck, no body, no limbs. Top right quadrant: ONLY a plump pear-shaped ivory furry TORSO, front view, rounded shoulders at top, round belly, no head no arms no legs, fully complete furry silhouette. Bottom left quadrant: ONLY ONE detached arm, a short plump ivory furry capsule limb with grey knit mitten at the TOP end and rounded ivory shoulder at BOTTOM end, almost vertical, viewed from front. Bottom right quadrant: ONLY ONE detached short plump ivory furry leg, ivory hip at TOP and rounded grey knit foot/sole at BOTTOM, angled a little toward camera to show soft grey sole. No extra pieces, no grid lines, no labels, no text, no assembled character, no extra characters, no ground shadows. True alpha-transparent background, no white backdrop, no checkerboard printed in image. Each part must be strictly inside its own quadrant and never touching neighboring parts. Full opaque fur on each part; just the background is transparent. This is a clean cutout sprite atlas for a 2D articulated puppet, not an instruction diagram.
