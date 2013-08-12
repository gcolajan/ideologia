<?php
function showCase($posCase, $typeCase, &$contenuCases) {
	switch ($typeCase) {
		case 'depart':
			$case = '
		<div id="case'.$posCase.'" class="case_'.$typeCase.'">
			<span id="case_s'.$posCase.'">Départ</span>
		</div>';
		break;
		case 'evenement':
			$case = '
		<div id="case'.$posCase.'" class="case_'.$typeCase.'">
			<span id="case_s'.$posCase.'">Événement</span>
		</div>';
		break;
		default:
			$contenu = $contenuCases[$posCase];
			$case = '
		<div id="case'.$posCase.'" class="case_'.$typeCase.'"
		onmouseover="highlightTerr('.$contenu['id'].')"
		onmouseout="highlightTerrOver('.$contenu['id'].')">
			<span id="case_s'.$posCase.'">'.$contenu['nom'].'</span>
		</div>';
	}
	
	return $case;
}
?>


	<div id="menu">
		<p style="text-align:center;"><img src="/assets/logo.png" alt="Ideologia" title="Ideologia" /></p>
		
			<div id="panel_general">
			<h2>Joueurs</h2>
				<div id="joueurs">
					<!-- remplir le title avec le pseudo -->
					<span class="jj"><span id="jj0">J1</span><span id="joueur_pseudo0">-</span></span>
					<span class="jj"><span id="jj1">J2</span><span id="joueur_pseudo1">-</span></span>
					<span class="jj"><span id="jj2">J3</span><span id="joueur_pseudo2">-</span></span>
					<span class="jj"><span id="jj3">J4</span><span id="joueur_pseudo3">-</span></span>
				</div>
			</div>


			<div id="panel_synthese">
			<h2>Synthèse</h2>
			
				<div style="margin:auto; width:90%; font-size:90%; margin-bottom:15px;">
					<div style="float:left; width:48%; border:1px solid black; border-radius:6px; text-align:center; background:white;">
						Territoires : <span id="synthese_territoires">-</span>	
					</div>
					<div style="margin-left:52%; border:1px solid black; border-radius:6px; text-align:center; background:white;">	
						Fonds : <span id="synthese_fonds">- $</span>
					</div>
				</div>

				<div class="jauges">
					<?php
						foreach ($listeJauges as $id => $jauge)
							echo '					<span class="jauge jauge'.$id.'" title="Jauge '.$jauge.'">
						<span class="conteneur_jauge">
							<span id="ideal'.$id.'" style="background-position:0 50%;"><span id="indicateur'.$id.'" style="height:50%;"><!-- indicateur interne --> </span></span>	<!-- coloration -->
							<span></span> <!-- contour jauge -->
							<span id="niveau'.$id.'" style="background-position:0px 50%;"></span> <!-- curseur -->
						</span>
		
						<span class="label" id="label_jauge'.$id.'">50%</span>
						<span class="ecart" id="ecart_jauge'.$id.'">Δ 0pts</span>
					</span>';
					?>
				</div>
			</div>
	</div>
	
	<div id="plateau">
	
		<div id="cases_droite"> <!-- Cases 11..21 -->
			<?php for($i = 11 ; $i <= 21 ; $i++)
				echo showCase($i, $typesCases[$i], $contenuCases)."\n";
			?>
		</div> 
		
		<div id="cases_gauche">
			<?php
			echo showCase(0, $typesCases[0], $contenuCases)."\n";
			for($i = 41 ; $i >= 32 ; --$i)
				echo showCase($i, $typesCases[$i], $contenuCases)."\n";
			?>
		</div> 
		
		<div id="cases_horizontales">
			<div id="cases_sup">
			<?php for($i = 1 ; $i <= 10 ; ++$i)
				echo showCase($i, $typesCases[$i], $contenuCases)."\n";
			?>
			</div>
			
			<div id="map">
	<span id="log"></span>
	<span id="consoleTerr"></span>
	<span id="etatPartie">
		<span class="des" id="de1"></span>
		<span class="des" id="de2"></span>
	</span>
	<span id="conteneurTimer">
		<span id="timer" title="Temps restant">30 : 00</span>
	</span>
	<span id="etatTerritoires" class="console"></span>
	<!-- TODO: Charger via Ajax -->
	<?php include 'carte.svg'; ?>
			</div>
			
			<div id="cases_inf">
			<?php for($i = 31 ; $i > 21 ; --$i)
				echo showCase($i, $typesCases[$i], $contenuCases)."\n";
			?>
			</div>
			
		</div>
	</div>
