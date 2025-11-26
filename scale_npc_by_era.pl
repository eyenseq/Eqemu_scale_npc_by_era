# quests/plugins/scale_npc_by_era.pl
# ==========================================================
# plugin::scale_npc_by_era([$npc, $zonesn])
#
# - Globally scales NPCs down or up by "era" with NO DB changes.
# - Era is determined by zone short name.
# - Can be called from any EVENT_SPAWN:
#       plugin::scale_npc_by_era();
# ==========================================================

# Toggle for chatty debug
our $ERA_SCALE_DEBUG //= 1; 

# ---------------- ERA CONFIG ----------------
# 1) Zones by era. Edit these lists for your server.
my %ERA_ZONES = (
    classic => [ qw(
        airplane		akanon			befallen		beholder
		butcher			cauldron		commonlands		blackburrow
		commons			crushbone		eastkarana		ecommons
		erudnext		erudnint		erudsxing		everfrost
		fearplane		feerrott		feerrott2		felwithea
		felwitheb		freeporteast	freeportwest	freporte
		freportn		freportw		gfaydark		grobb
		gukbottom		guktop			halas			highkeep
		highpass		highpasshold	toxxulia		innothule
		innothuleb		kaladima		kaladimb		kedge
		kithicor		lakerathe		lavastorm		lfaydark
		mistmoore		misty			mistythicket	najena
		nektulos		neriaka			neriakb			neriakc
		northkarana		northro			nro				oasis
		oceanoftears	oggok			oot				paineel
		befallen		permafrost		qcat			qey2hh1
		qeynos			qeynos2			qeytoqrg		qrg
		rathemtn		rivervale		runnyeye		soldunga
		soldungb		soldungc		soltemple		southkarana
		southro			sro				steamfont		steamfontmts
		befallenb		tox						
								
		
		
    ) ],

    kunark => [ qw(
		burningwood		cabeast			cabwest			chardok
		citymist		dalnir			dreadlands		firiona
		frontiermtns	charasis		kaesora			karnor
		kurn			lakeofillomen	warslikswood	sebilis
		hole			skyfire			swampofnohope	veeshan
		emeraldjungle	fieldofbone		overthere		timorous
		trakanon							
        

    ) ],

    velious => [ qw(
        cobaltscar		crystal			necropolis		eastwastes
		greatdivide		iceclad			icewell			kael
		sleep			fearplane		growthplane		wakening
		velketor		siren			skyshrine		stonebrunt
		templeveeshan	warrens			westwastes		thurgadina
		thurgadinb		frozenshadow			
		
    ) ],

    luclin => [ qw(
        acrylia			akheva			dawnshroud		echo
		griegsend		grimling		hollowshade		jaggedpine
		katta			mseru			letalis			netherbian
		paludal			sseru			scarlet			shadeweaver
		shadowhaven		sharvahl		ssratemple		tenebrous
		bazaar			thedeep			fungusgrove		thegrey
		maiden			nexus			twilight		umbral
		vexthal
		
    ) ],

    pop => [ qw(
        pofire			potactics		poair			hohonora
		hohonorb		ponightmare		nightmareb		podisease
		poinnovation	pojustice		postorms		potimea
		potimeb			potorment		potranquility	povalor
		poeartha		poearthb		powater			codecay
		solrotower		poknowledge		bothunder		
		
    ) ],
	
	loy => [ qw(
		soldungc		cazicthule		dulak			gunthak
		chardokb		hatesfury		nurga			hateplaneb
		droga			nadox			torgiran		veksar
		
	) ],
	
	ldon => [ qw(
		guka           	gukb           	gukc           	gukd
		guke		   	gukf			gukg			gukh
		mmca		  	mmcb			mmcc			mmcd
		mmce		  	mmcf			mmcg			mmch
		mmci	  	  	mmcj			ruja			rujb
		rujc		  	rujd			rujc			rujd
		ruje		  	rujf			rujg			rujh
		ruji		 	rujj			mira			mirb
		mirc		 	mird			mire			mirf
		mirg		 	mirh			miri			mirj
		takishruins  	takishruinsa  	paw 			nedaria
	) ],
	
	god => [ qw(
		abysmal			barindu			ferubi			ikkinz
		inktuta			kodtaz			natimbi			mischiefplane
		qinimi			qvic			riwwi			snpool
		snlair			snplant			sncrematory		shadowrest
		tacvi			fhalls			tipt			txevu
		uqua			vxed			yxtta
		
	) ],
	
	oow => [ qw(
		draniksscar    	dranik         dranikb          wallofslaughter
		bloodfields    	ruinedcity     nobles           draniksscar
		anguish       	catacombs      provinggrounds   causeway
	) ],
);

# 2) Era multipliers (tune for your server)
#    hp      = HP
#    melee   = min/max hit
#    defense = AC / tankiness
#    atk     = ATK + accuracy
#    resist  = MR/FR/CR/DR/PR/Corruption
#    spell   = spellscale / healscale
my %ERA_SCALE = (
    classic => {
        hp      => 0.40,
        melee   => 0.40,
        defense => 0.50,
        atk     => 0.35,
        resist  => 0.50,
        spell   => 0.50,
    },
    kunark  => {
        hp      => 0.55,
        melee   => 0.55,
        defense => 0.65,
        atk     => 0.55,
        resist  => 0.60,
        spell   => 0.65,
    },
    velious => {
        hp      => 0.70,
        melee   => 0.70,
        defense => 0.80,
        atk     => 0.70,
        resist  => 0.75,
        spell   => 0.80,
    },
    luclin  => {
        hp      => 0.85,
        melee   => 0.85,
        defense => 0.90,
        atk     => 0.85,
        resist  => 0.90,
        spell   => 0.95,
    },
    pop     => {
        hp      => 0.50,
        melee   => 0.50,
        defense => 0.50,
        atk     => 0.50, 
        resist  => 0.50,
        spell   => 0.50,
    },
    loy     => {
        hp      => 0.50,
        melee   => 0.50,
        defense => 0.50,
        atk     => 0.50, 
        resist  => 0.50,
        spell   => 0.50,
    },
    ldon    => {
        hp      => 0.50,
        melee   => 0.50,
        defense => 0.50,
        atk     => 0.50, 
        resist  => 0.50,
        spell   => 0.50,
    },
    god     => {
        hp      => 0.50,
        melee   => 0.50,
        defense => 0.50,
        atk     => 0.50, 
        resist  => 0.50,
        spell   => 0.50,
    },
    oow     => {
        hp      => 0.50,
        melee   => 0.50,
        defense => 0.50,
        atk     => 0.50, 
        resist  => 0.50,
        spell   => 0.50,
    },
);

# ---------------- NPC BLACKLIST ----------------
# NPC type IDs that should NEVER be scaled.
# Example: training dummy, bosses, banker-like utility NPCs.

my %ERA_BLACKLIST_NPCID = (
    282020 => 1,   # Training Dummy
    # 90001 => 1,   # Custom boss example
    # 90002 => 1,
);


# Fallback if zone/era not mapped
my %DEFAULT_SCALE = (
    hp      => 1.00,
    melee   => 1.00,
    defense => 1.00,
    atk     => 1.00,
    resist  => 1.00,
    spell   => 1.00,
);

# Flat map zone_short -> era (lazy-init)
our %ZONE_ERA;
our $ERA_SCALE_INITED = 0;

sub _era_build_zone_map {
    %ZONE_ERA = ();
    for my $era (keys %ERA_ZONES) {
        for my $z (@{ $ERA_ZONES{$era} }) {
            my $zn = lc $z;
            $ZONE_ERA{$zn} = $era;
        }
    }
    $ERA_SCALE_INITED = 1;
    if ($ERA_SCALE_DEBUG) {
        quest::debug("[EraScale] Built ZONE_ERA map with " . scalar(keys %ZONE_ERA) . " entries");
    }
}

# ==========================================================
# PUBLIC: plugin::scale_npc_by_era([$npc, $zonesn])
# ==========================================================
sub plugin::scale_npc_by_era {
    my ($npc, $zone) = @_;

    _era_build_zone_map() unless $ERA_SCALE_INITED;

    # Allow optional args or auto-grab from quest context
    $npc  ||= plugin::val('npc');
    $zone ||= plugin::val('zonesn');

    return if !_era_should_scale_npc($npc);

    my $zonesn = lc($zone // '');

    my $era;
    if (exists $ZONE_ERA{$zonesn}) {
        $era = $ZONE_ERA{$zonesn};
    } else {
        $era = 'default';
    }

    my $prof = $era eq 'default'
        ? \%DEFAULT_SCALE
        : $ERA_SCALE{$era} || \%DEFAULT_SCALE;

    if ($ERA_SCALE_DEBUG) {
        quest::debug(
            sprintf(
                "[EraScale] map lookup: zone=%s -> era=%s (hp=%.2f melee=%.2f def=%.2f atk=%.2f resist=%.2f spell=%.2f)",
                $zonesn,
                $era,
                $prof->{hp}, $prof->{melee}, $prof->{defense},
                $prof->{atk}, $prof->{resist}, $prof->{spell},
            )
        );
    }

    _era_apply_scale_profile($npc, $zonesn, $era, $prof);
}

# ----------------------------------------------------------
# INTERNAL: filter which NPCs get scaled
# ----------------------------------------------------------
sub _era_should_scale_npc {
    my ($npc) = @_;
    return 0 if !$npc;
    return 0 if $npc->IsClient();   # skip players
    return 0 if $npc->IsPet();      # skip pets
    return 0 if $npc->IsCorpse();   # skip corpses

    # Skip merchants, bankers, etc.
    my $class = $npc->GetClass();
    return 0 if $class == 41;       # merchant
    return 0 if $class == 40;       # banker

    # Skip 1 HP props/traps
    my $hp = $npc->GetMaxHP();
    return 0 if $hp <= 1;

    # --- BLACKLIST LOGIC ---
    my $npc_id = $npc->GetNPCTypeID() || 0;
    if ($ERA_BLACKLIST_NPCID{$npc_id}) {
        return 0;
    }

    return 1;
}


# ----------------------------------------------------------
# INTERNAL: apply scale profile (full knobs)
# ----------------------------------------------------------
sub _era_apply_scale_profile {
    my ($npc, $zone, $era, $prof) = @_;

    my $hp_mult     = $prof->{hp}      // 1.0;
    my $melee_mult  = $prof->{melee}   // 1.0;
    my $def_mult    = $prof->{defense} // $hp_mult;
    my $atk_mult    = $prof->{atk}     // $melee_mult;
    my $resist_mult = $prof->{resist}  // $prof->{spell} // 1.0;
    my $spell_mult  = $prof->{spell}   // 1.0;

    # -------- Base combat stats --------
    my $orig_hp   = $npc->GetMaxHP();
    my $orig_min  = $npc->GetMinDMG();
    my $orig_max  = $npc->GetMaxDMG();
    my $orig_ac   = $npc->GetAC();
    my $orig_atk  = $npc->GetATK();
    my $orig_acc  = $npc->GetAccuracyRating();

    # -------- Resists --------
    my $orig_mr   = $npc->GetMR();
    my $orig_fr   = $npc->GetFR();
    my $orig_cr   = $npc->GetCR();
    my $orig_dr   = $npc->GetDR();
    my $orig_pr   = $npc->GetPR();
    my $orig_cor  = $npc->GetCorruption();

    # -------- New values (scaled) --------
    my $new_hp    = int($orig_hp  * $hp_mult);
    my $new_min   = int($orig_min * $melee_mult);
    my $new_max   = int($orig_max * $melee_mult);

    my $new_ac    = int($orig_ac  * $def_mult);
    my $new_atk   = int($orig_atk * $atk_mult);
    my $new_acc   = int($orig_acc * $atk_mult);

    my $new_mr    = int($orig_mr  * $resist_mult);
    my $new_fr    = int($orig_fr  * $resist_mult);
    my $new_cr    = int($orig_cr  * $resist_mult);
    my $new_dr    = int($orig_dr  * $resist_mult);
    my $new_pr    = int($orig_pr  * $resist_mult);
    my $new_cor   = int($orig_cor * $resist_mult);

    # -------- Safety clamps --------
    $new_hp  = 1 if $new_hp < 1 && $orig_hp > 0;

    if ($orig_min > 0) {
        $new_min = 1 if $new_min < 1;
    }
    if ($new_max < $new_min) {
        $new_max = $new_min;
    }

    $new_ac  = 0 if $new_ac  < 0;
    $new_atk = 0 if $new_atk < 0;
    $new_acc = 0 if $new_acc < 0;

    $new_mr  = 0 if $new_mr  < 0;
    $new_fr  = 0 if $new_fr  < 0;
    $new_cr  = 0 if $new_cr  < 0;
    $new_dr  = 0 if $new_dr  < 0;
    $new_pr  = 0 if $new_pr  < 0;
    $new_cor = 0 if $new_cor < 0;

    # -------- Apply stat changes --------
    $npc->ModifyNPCStat("max_hp",  $new_hp);
    $npc->ModifyNPCStat("min_hit", $new_min);
    $npc->ModifyNPCStat("max_hit", $new_max);

    $npc->ModifyNPCStat("ac",       $new_ac);
    $npc->ModifyNPCStat("atk",      $new_atk);
    $npc->ModifyNPCStat("accuracy", $new_acc);

    $npc->ModifyNPCStat("mr",      $new_mr);
    $npc->ModifyNPCStat("fr",      $new_fr);
    $npc->ModifyNPCStat("cr",      $new_cr);
    $npc->ModifyNPCStat("dr",      $new_dr);
    $npc->ModifyNPCStat("pr",      $new_pr);
    $npc->ModifyNPCStat("cor",  $new_cor);

    my $spellscale = int($spell_mult * 100);
    $npc->ModifyNPCStat("spellscale", $spellscale);
    $npc->ModifyNPCStat("healscale",  $spellscale);

    $npc->Heal();

    if ($ERA_SCALE_DEBUG) {
        quest::debug(
            sprintf(
                "[EraScale] zone=%s era=%s ".
                "hp %.0f->%.0f (x%.2f) ".
                "min %.0f->%.0f (x%.2f) max %.0f->%.0f (x%.2f) ".
                "ac %.0f->%.0f (x%.2f) atk %.0f->%.0f (x%.2f) ".
                "mr %.0f->%.0f fr %.0f->%.0f cr %.0f->%.0f ".
                "dr %.0f->%.0f pr %.0f->%.0f cor %.0f->%.0f (resist x%.2f) ".
                "spell x%.2f",
                $zone, $era,
                $orig_hp,  $new_hp,  $hp_mult,
                $orig_min, $new_min, $melee_mult,
                $orig_max, $new_max, $melee_mult,
                $orig_ac,  $new_ac,  $def_mult,
                $orig_atk, $new_atk, $atk_mult,
                $orig_mr,  $new_mr,
                $orig_fr,  $new_fr,
                $orig_cr,  $new_cr,
                $orig_dr,  $new_dr,
                $orig_pr,  $new_pr,
                $orig_cor, $new_cor, $resist_mult,
                $spell_mult,
            )
        );
    }
}

1;
