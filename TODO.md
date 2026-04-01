# Professional UI Upgrade for CuiMainChar - ONLY UI Changes

Status: 0/15 steps completed ✅

## Plan Overview
Transform current gradient-heavy design to modern glassmorphism + Material You inspired by provided HTML splash (purple/lime theme, mesh grads, noise, hero text, badge, CTA, avatar stack).

**Colors**: primary #d394ff/#cb80ff, secondary #c3f400, bg #0e0e0e, surfaces #1a1a1a.
**Fonts**: Epilogue (headline), Plus Jakarta Sans (body), Space Grotesk (label).
**Effects**: BackdropFilter glass, radial mesh grads, shimmer, flutter_animate transitions.

## Step-by-Step TODO

### Phase 1: Setup & Splash (Priority from user HTML)
- [ ] 1. Update pubspec.yaml: confirm google_fonts covers Epilogue/PlusJakarta/SpaceGrotesk (already does). Add `shimmer: ^3.0.0` for loadings.
- [ ] 2. Execute `flutter pub get`
- [x] 3. Update lib/main.dart: new ColorScheme (primary Color(0xFFD394FF), secondary Color(0xFFC3F400), fonts: epilogue/plus_jakarta_display/space_grotesk) **COMPLETE**
- [x] 4. **Convert splash_screen.dart to HTML design**: Stack with noise painter, animated mesh grads, verification badge, 'CAMPUS VIBE' hero, subtitle, CTA 'Be the Main Character', avatars stack, '12k+ active' **COMPLETE**
- [ ] 5. Test splash: `flutter run`

### Phase 2: Core Screens
- [ ] 6. login_screen.dart: Glass input cards, hero campus img, pulse CTA
- [ ] 7. profile_setup_screen.dart & edit_profile_screen.dart: Glass forms, shimmer avatar upload
- [ ] 8. voting_arena_screen.dart: Glass card swipes, parallax scale, like confetti
- [ ] 9. profile_screen.dart: Glowing avatar, radial progress stats
- [ ] 10. leaderboard_screen.dart: Podium top3 stack, animated list stagger
- [ ] 11. nav_wrapper.dart: Glass nav bar, vote badge anims

### Phase 3: Polish & Theme
- [ ] 12. app_pages.dart: Custom page transitions (hero curves)
- [ ] 13. Global: Hero animations between screens, consistent glass widgets
- [ ] 14. Add assets: noise.png (or CustomPainter), campus illustrations
- [ ] 15. Full test `flutter run`, hot reload checks

**Current Progress**: Starting with splash conversion per user HTML inspo.

**Notes**: NO logic changes. Pure UI. Test after each phase.

