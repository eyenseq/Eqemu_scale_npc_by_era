# quests/plugins/scale_npc_by_era.pl
# ==========================================================
# plugin::scale_npc_by_era([$npc, $zonesn, $zone_version])
#
# - Globally scales NPCs down or up by "era" with NO DB changes.
# - Era is determined by zone short name.
# - Can be called from any EVENT_SPAWN:
#       plugin::scale_npc_by_era();
#
#   Optional args:
#       plugin::scale_npc_by_era($npc);
#       plugin::scale_npc_by_era($npc, $zonesn);
#       plugin::scale_npc_by_era($npc, $zonesn, $zone_version);
# ==========================================================

package plugin;

# Toggle for chatty debug
our $ERA_SCALE_DEBUG //= 0;

# ---------------- ERA CONFIG ----------------
# 1) Zones by era. Edit these lists for your server.
my %ERA_ZONES = (
    classic => [ qw(
        airplane akanon befallen befallenb beholder blackburrow butcher cauldron
        commonlands commons crushbone eastkarana ecommons erudnext erudnint
        erudsxing everfrost feerrott felwithea felwitheb freeporteast
        freeportwest freporte freportn freportw gfaydark grobb
        gukbottom guktop halas highkeep highpass highpasshold
        innothule innothuleb kaladima kaladimb kedge kithicor
        lakerathe lavastorm lfaydark mistmoore misty mistythicket
        najena nektulos neriaka neriakb neriakc northkarana northro
        nro oasis oceanoftears oggok oot paineel permafrost qcat
        qey2hh1 qeynos qeynos2 qeytoqrg qrg rathemtn rivervale
        runnyeye soldunga soldungb soltemple southkarana southro
        sro steamfont steamfontmts tox
    ) ],

    kunark => [ qw(
        burningwood cabeast cabwest chardok charasis citymist dalnir
        dreadlands emeraldjungle fieldofbone firiona frontiermtns
        kaesora karnor kurn lakeofillomen overthere sebilis skyfire
        swampofnohope timorous trakanon veeshan warslikswood
    ) ],

    velious => [ qw(
        cobaltscar crystal eastwastes fearplane frozenshadow
        greatdivide growthplane iceclad icewell kael necropolis
        siren skyshrine sleep stonebrunt templeveeshan thurgadina
        thurgadinb velketor wakening warrens westwastes
    ) ],

    luclin => [ qw(
        acrylia akheva bazaar dawnshroud echo fungusgrove
        griegsend grimling hollowshade jaggedpine katta letalis
        maiden mseru netherbian nexus paludal scarlet shadeweaver
        shadowhaven sharvahl ssratemple sseru tenebrous thedeep
        thegrey twilight umbral vexthal
    ) ],

    pop => [ qw(
        bothunder codecay guildhall guildlobby hohonora hohonorb
        nightmareb poair podisease poeartha poearthb pofire
        poinnovation poj ponightmare poknowledge postorms
        potactics potimea potimeb potorment potranquility
        povalor powar powater solrotower
    ) ],

    loy => [ qw(
        cazicthule chardokb droga dulak gunthak hateplaneb
        hatesfury nadox nurga paw soldungc torgiran veksar
    ) ],

    ldon => [ qw(
        guka gukb gukc gukd guke gukf gukg gukh mira mirb mirc
        mird mire mirf mirg mirh miri mirj mmca mmcb mmcc mmcd
        mmce mmcf mmcg mmch mmci mmcj nedaria ruja rujb rujc
        rujd ruje rujf rujg rujh ruji rujj taka takishruins
        takishruinsa
    ) ],

    god => [ qw(
        abysmal barindu ferubi fhalls ikkinz inktuta kodtaz
        mischiefplane natimbi qinimi qvic riwwi shadowrest
        sncrematory snlair snplant snpool tacvi tipt txevu
        uqua vxed yxtta
    ) ],

    oow => [ qw(
        anguish bloodfields causeway chambersa chambersb
        chambersc chambersd chamberse chambersf
        dranikcatacombsa dranikcatacombsb dranikcatacombsc
        dranikhollowsa dranikhollowsb dranikhollowsc
        draniksewersa draniksewersb draniksewersc draniksscar
        nobles provinggrounds riftseekers ruinedcity
        wallofslaughter
    ) ],

    don => [ qw(
        broodlands delvea delveb stillmoona stillmoonb
        thenest thundercrest
    ) ],

    dodh => [ qw(
        corathus corathusa corathusb drachnidhive drachnidhivea
        drachnidhiveb drachnidhivec dreadspire eastkorlach
        eastkorlacha illsalin illsalina illsalinb illsalinc
        shadowspine westkorlach westkorlacha westkorlachb
        westkorlachc
    ) ],

    por => [ qw(
        arcstone devastation devastationa elddar elddara
        rage ragea relic theater theatera
    ) ],

    tss => [ qw(
        ashengate crescent direwind frostcrypt icefall
        mesa moors roost steppes stonehive
        sunderock valdeholm vergalid
    ) ],

    tbs => [ qw(
        atiiki barren barter blacksail buriedsea deadbone
        jardelshook maidensgrave monkeyrock redfeather
        shipmvm shipmvp shipmvu shippvu shipuvu silyssar
        solteris suncrest thalassius zhisza
    ) ],

    sof => [ qw(
        bloodmoon cryptofshade crystallos dragonscale
        dragonscaleb guardian gyrospireb gyrospirez
        hillsofshade lopingplains mansion mechanotus
        shipworkshop steamfactory
    ) ],

    sod => [ qw(
        bertoxtemple discord discordtower korascian
        oceangreenhills oceangreenvillage oldblackburrow
        oldbloodfield oldcommons olddranik oldfieldofbone
        oldhighpass oldkaesoraa oldkaesorab oldkithicor
        oldkurn precipiceofwar rathechamber
        thevoida thevoidb thevoidc thevoidd thevoide
        thevoidf thevoidg toskirakk
    ) ],

    uf => [ qw(
        arthicrex brellsarena brellsrest brellstemple
        convorteum coolingchamber foundation fungalforest
        lichencreep pellucid shiningcity stonesnake
        underquarry
    ) ],

    hot => [ qw(
        alkabormare fallen feerrott2 housegarden
        miragulmare morellcastle nektulosa
        neighborhood somnium thulehouse1
        thulehouse2 thulelibrary thuledream
        well
    ) ],

    voa => [ qw(
        arelis argath beastdomain cityofbronze
        eastsepulcher pillarsalra resplendent
        rubak sarithcity sepulcher westsepulcher
        windsong
    ) ],

    rof => [ qw(
        breedinggrounds chapterhouse crystalshard
        eastwastesshard eviltree grelleth
        kaelshard shardslanding xorbb
    ) ],
);

# 2) Era multipliers (tune for your server)
# Each era now has:
#   trash => !$npc->IsRaidTarget() && !$npc->IsRareSpawn()
#   named =>  $npc->IsRareSpawn()
#   raid  =>  $npc->IsRaidTarget()
my %ERA_SCALE = (
    classic => {
        trash => {
            hp      => 0.40,
            melee   => 0.40,
            defense => 0.50,
            atk     => 0.35,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.40,
            melee   => 0.40,
            defense => 0.50,
            atk     => 0.35,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.40,
            melee   => 0.40,
            defense => 0.50,
            atk     => 0.35,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },

    kunark => {
        trash => {
            hp      => 0.55,
            melee   => 0.55,
            defense => 0.65,
            atk     => 0.55,
            resist  => 0.60,
            spell   => 0.65,
            mana    => 1.00,
        },
        named => {
            hp      => 0.55,
            melee   => 0.55,
            defense => 0.65,
            atk     => 0.55,
            resist  => 0.60,
            spell   => 0.65,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.55,
            melee   => 0.55,
            defense => 0.65,
            atk     => 0.55,
            resist  => 0.60,
            spell   => 0.65,
            mana    => 1.00,
        },
    },

    velious => {
        trash => {
            hp      => 0.70,
            melee   => 0.70,
            defense => 0.80,
            atk     => 0.70,
            resist  => 0.75,
            spell   => 0.80,
            mana    => 1.00,
        },
        named => {
            hp      => 0.70,
            melee   => 0.70,
            defense => 0.80,
            atk     => 0.70,
            resist  => 0.75,
            spell   => 0.80,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.70,
            melee   => 0.70,
            defense => 0.80,
            atk     => 0.70,
            resist  => 0.75,
            spell   => 0.80,
            mana    => 1.00,
        },
    },

    luclin => {
        trash => {
            hp      => 0.85,
            melee   => 0.85,
            defense => 0.90,
            atk     => 0.85,
            resist  => 0.90,
            spell   => 0.95,
            mana    => 1.00,
        },
        named => {
            hp      => 0.85,
            melee   => 0.85,
            defense => 0.90,
            atk     => 0.85,
            resist  => 0.90,
            spell   => 0.95,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.85,
            melee   => 0.85,
            defense => 0.90,
            atk     => 0.85,
            resist  => 0.90,
            spell   => 0.95,
            mana    => 1.00,
        },
    },

    pop => {
        trash => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },

    loy => {
        trash => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },

    ldon => {
        trash => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },

    god => {
        trash => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },

    oow => {
        trash => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },
	don => {
        trash => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },
	dodh => {
        trash => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },
	por => {
        trash => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },
	tss => {
        trash => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },
	tbs => {
        trash => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },
	sof => {
        trash => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },
	sod => {
        trash => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },
	uf => {
        trash => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },
	hot => {
        trash => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },
	voa => {
        trash => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },
	rof => {
        trash => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        named => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
        raid  => {
            hp      => 0.50,
            melee   => 0.50,
            defense => 0.50,
            atk     => 0.50,
            resist  => 0.50,
            spell   => 0.50,
            mana    => 1.00,
        },
    },
);

# ---------------- NPC BLACKLIST ----------------
# NPC type IDs that should NEVER be scaled.
my %ERA_BLACKLIST_NPCID = (
    # 282020 => 1,   
    # 90001  => 1,
    # 90002  => 1,
);

# ---------------- ZONE VERSION BLACKLIST ----------------
# Per-zone *version* blacklist.
# Uses $zonesn and $instanceversion (0 = base zone).
# Example:
#   poknowledge => { 1 => 1 }  # don't touch version 1 of PoK (AoC instance, etc.)
my %ERA_BLACKLIST_ZONEVER = (
    # poknowledge => { 1 => 1 },
    # hateplane   => { 1 => 1 },
	
);

our %ERA_GLOBAL_VERSION_BLACKLIST = (
    # version => 1
    # 1 => 1,    # example: skip ALL version 1 zones (custom zones, AoC instances, LDoN, etc)
);

# ---------------- ROLE FILTERS ----------------
# Control which roles get scaled by era.
# If a role is 0 for a given era, scaling is entirely skipped for that NPC.
#
# Examples you can uncomment/adjust:
#   classic => { trash => 1, named => 1, raid => 0 },   # no Classic raids touched
#   god     => { trash => 0, named => 1, raid => 1 },   # only named+raids in GoD
my %ERA_ROLE_FILTER = (
    default => { trash => 1, named => 1, raid => 1 },

    # classic => { trash => 1, named => 1, raid => 0 },
    # kunark  => { trash => 1, named => 1, raid => 1 },
    # velious => { trash => 1, named => 1, raid => 1 },
    # luclin  => { trash => 1, named => 1, raid => 1 },
    # pop     => { trash => 1, named => 1, raid => 1 },
    # loy     => { trash => 1, named => 1, raid => 1 },
    # ldon    => { trash => 1, named => 1, raid => 1 },
    # god     => { trash => 1, named => 1, raid => 1 },
    # oow     => { trash => 1, named => 1, raid => 1 },
);

# Fallback if zone/era not mapped
my %DEFAULT_SCALE = (
    hp      => 1.00,
    melee   => 1.00,
    defense => 1.00,
    atk     => 1.00,
    resist  => 1.00,
    spell   => 1.00,
    mana    => 1.00,
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
    quest::debug("[EraScale] Built ZONE_ERA map with " . scalar(keys %ZONE_ERA) . " entries")
        if $ERA_SCALE_DEBUG;
}

# -------- role classifier: trash / named / raid ----------
sub _era_classify_role {
    my ($npc) = @_;
    return 'raid'  if $npc->IsRaidTarget();
    return 'named' if $npc->IsRareSpawn();
    return 'trash';
}

# ==========================================================
# PUBLIC: plugin::scale_npc_by_era([$npc, $zonesn, $zone_version])
# ==========================================================
sub scale_npc_by_era {
    my ($npc, $zone, $version) = @_;

    _era_build_zone_map() unless $ERA_SCALE_INITED;

    # Allow optional args or auto-grab from quest context
    $npc    ||= plugin::val('npc');
    $zone   ||= plugin::val('zonesn');
    $version = plugin::val('instanceversion') if !defined $version;

    return if !_era_should_scale_npc($npc);

    my $zonesn        = lc($zone // '');
    my $inst_version  = defined $version ? int($version) : 0;

	# --- Global version blacklist ---
	if (exists $ERA_GLOBAL_VERSION_BLACKLIST{$inst_version}) {
		quest::debug(
			sprintf(
				"[EraScale] Skipping zone=%s ver=%d due to GLOBAL version blacklist",
				$zonesn, $inst_version
			)
		) if $ERA_SCALE_DEBUG;
		return;
	}

	# --- Per-zone version blacklist ---
	if (exists $ERA_BLACKLIST_ZONEVER{$zonesn}
		&& exists $ERA_BLACKLIST_ZONEVER{$zonesn}{$inst_version})
	{
		quest::debug(
			sprintf(
				"[EraScale] Skipping zone=%s ver=%d due to zone-specific version blacklist",
				$zonesn, $inst_version
			)
		) if $ERA_SCALE_DEBUG;
		return;
	}


    my $era  = exists $ZONE_ERA{$zonesn} ? $ZONE_ERA{$zonesn} : 'default';
    my $role = _era_classify_role($npc);

    # --- Role filter per era (trash/named/raid on/off) ---
    my $rf = $ERA_ROLE_FILTER{$era} || $ERA_ROLE_FILTER{default} || { trash => 1, named => 1, raid => 1 };
    if (!$rf->{$role}) {
        quest::debug(
            sprintf(
                "[EraScale] Skipping npc_id=%d in zone=%s ver=%d era=%s role=%s due to role filter",
                ($npc->GetNPCTypeID() || 0), $zonesn, $inst_version, $era, $role
            )
        ) if $ERA_SCALE_DEBUG;
        return;
    }

    my $prof;
    if ($era eq 'default') {
        $prof = \%DEFAULT_SCALE;
    } else {
        my $era_cfg = $ERA_SCALE{$era};
        if (ref($era_cfg) eq 'HASH'
            && (exists $era_cfg->{trash} || exists $era_cfg->{named} || exists $era_cfg->{raid}))
        {
            # per-role config
            $prof = $era_cfg->{$role}
                 || $era_cfg->{trash}
                 || \%DEFAULT_SCALE;
        } else {
            # backwards-compatible flat era config
            $prof = $era_cfg || \%DEFAULT_SCALE;
        }
    }

    if ($ERA_SCALE_DEBUG) {
        quest::debug(
            sprintf(
                "[EraScale] map lookup: zone=%s ver=%d -> era=%s role=%s ".
                "(hp=%.2f melee=%.2f def=%.2f atk=%.2f resist=%.2f spell=%.2f mana=%.2f)",
                $zonesn, $inst_version,
                $era,
                $role,
                $prof->{hp},      $prof->{melee},
                $prof->{defense}, $prof->{atk},
                $prof->{resist},  $prof->{spell},
                $prof->{mana} // 1.00,
            )
        );
    }

    _era_apply_scale_profile($npc, $zonesn, $era, $role, $prof, $inst_version);
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
	return 0 if $npc->IsBot();   # skip Bots
	return 0 if $npc->IsAura();   # skip Aura
	return 0 if $npc->IsMerc();   # skip Merc 

    # Skip merchants, bankers, etc.
    my $class = $npc->GetClass();
    return 0 if $class == 41;       # merchant
    return 0 if $class == 40;       # banker

    # Skip 1 HP props/traps
    my $hp = $npc->GetMaxHP();
    return 0 if $hp <= 1;

    # --- BLACKLIST LOGIC ---
    my $npc_id = $npc->GetNPCTypeID() || 0;
    return 0 if $ERA_BLACKLIST_NPCID{$npc_id};

    return 1;
}

# ----------------------------------------------------------
# INTERNAL: apply scale profile (full knobs)
# ----------------------------------------------------------
sub _era_apply_scale_profile {
    my ($npc, $zone, $era, $role, $prof, $version) = @_;

    my $hp_mult     = $prof->{hp}      // 1.0;
    my $melee_mult  = $prof->{melee}   // 1.0;
    my $def_mult    = $prof->{defense} // $hp_mult;
    my $atk_mult    = $prof->{atk}     // $melee_mult;
    my $resist_mult = $prof->{resist}  // $prof->{spell} // 1.0;
    my $spell_mult  = $prof->{spell}   // 1.0;
    my $mana_mult   = $prof->{mana}    // 1.0;

    # -------- Base combat stats --------
    my $orig_hp    = $npc->GetMaxHP();
    my $orig_min   = $npc->GetMinDMG();
    my $orig_max   = $npc->GetMaxDMG();
    my $orig_ac    = $npc->GetAC();
    my $orig_atk   = $npc->GetATK();
    my $orig_acc   = $npc->GetAccuracyRating();
    my $orig_mana  = $npc->GetMaxMana();

    # -------- Resists --------
    my $orig_mr    = $npc->GetMR();
    my $orig_fr    = $npc->GetFR();
    my $orig_cr    = $npc->GetCR();
    my $orig_dr    = $npc->GetDR();
    my $orig_pr    = $npc->GetPR();
    my $orig_cor   = $npc->GetCorruption();

    # -------- New values (scaled) --------
    my $new_hp     = int($orig_hp   * $hp_mult);
    my $new_min    = int($orig_min  * $melee_mult);
    my $new_max    = int($orig_max  * $melee_mult);

    my $new_ac     = int($orig_ac   * $def_mult);
    my $new_atk    = int($orig_atk  * $atk_mult);
    my $new_acc    = int($orig_acc  * $atk_mult);

    my $new_mr     = int($orig_mr   * $resist_mult);
    my $new_fr     = int($orig_fr   * $resist_mult);
    my $new_cr     = int($orig_cr   * $resist_mult);
    my $new_dr     = int($orig_dr   * $resist_mult);
    my $new_pr     = int($orig_pr   * $resist_mult);
    my $new_cor    = int($orig_cor  * $resist_mult);

    my $new_mana   = int($orig_mana * $mana_mult);

    # -------- Safety clamps --------
    $new_hp  = 1 if $new_hp < 1 && $orig_hp > 0;

    if ($orig_min > 0) {
        $new_min = 1 if $new_min < 1;
    }
    if ($new_max < $new_min) {
        $new_max = $new_min;
    }

    $new_ac   = 0 if $new_ac   < 0;
    $new_atk  = 0 if $new_atk  < 0;
    $new_acc  = 0 if $new_acc  < 0;

    $new_mr   = 0 if $new_mr   < 0;
    $new_fr   = 0 if $new_fr   < 0;
    $new_cr   = 0 if $new_cr   < 0;
    $new_dr   = 0 if $new_dr   < 0;
    $new_pr   = 0 if $new_pr   < 0;
    $new_cor  = 0 if $new_cor  < 0;

    $new_mana = 0 if $new_mana < 0;

    # -------- Apply stat changes --------
    $npc->ModifyNPCStat("max_hp",   $new_hp);
    $npc->ModifyNPCStat("min_hit",  $new_min);
    $npc->ModifyNPCStat("max_hit",  $new_max);

    $npc->ModifyNPCStat("ac",       $new_ac);
    $npc->ModifyNPCStat("atk",      $new_atk);
    $npc->ModifyNPCStat("accuracy", $new_acc);

    $npc->ModifyNPCStat("mr",       $new_mr);
    $npc->ModifyNPCStat("fr",       $new_fr);
    $npc->ModifyNPCStat("cr",       $new_cr);
    $npc->ModifyNPCStat("dr",       $new_dr);
    $npc->ModifyNPCStat("pr",       $new_pr);
    $npc->ModifyNPCStat("cor",      $new_cor);

    $npc->ModifyNPCStat("max_mana", $new_mana);

    my $spellscale = int($spell_mult * 100);
    $npc->ModifyNPCStat("spellscale", $spellscale);
    $npc->ModifyNPCStat("healscale",  $spellscale);

    $npc->Heal() if !$npc->IsEngaged();

    if ($ERA_SCALE_DEBUG) {
        my $ver = defined $version ? int($version) : 0;
        quest::debug(
            sprintf(
                "[EraScale] zone=%s ver=%d era=%s role=%s ".
                "hp %.0f->%.0f (x%.2f) ".
                "min %.0f->%.0f (x%.2f) max %.0f->%.0f (x%.2f) ".
                "ac %.0f->%.0f (x%.2f) atk %.0f->%.0f (x%.2f) ".
                "mr %.0f->%.0f fr %.0f->%.0f cr %.0f->%.0f ".
                "dr %.0f->%.0f pr %.0f->%.0f cor %.0f->%.0f (resist x%.2f) ".
                "mana %.0f->%.0f (x%.2f) spell x%.2f",
                $zone, $ver, $era, $role,
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
                $orig_mana, $new_mana, $mana_mult,
                $spell_mult,
            )
        );
    }
}

1;
