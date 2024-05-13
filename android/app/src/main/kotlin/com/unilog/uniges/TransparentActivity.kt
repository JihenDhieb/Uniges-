package com.unilog.uniges
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import android.widget.EditText
import android.widget.Button
import android.content.Intent 
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngineCache
import androidx.appcompat.app.AppCompatActivity
import androidx.core.widget.NestedScrollView 
import io.flutter.plugin.common.MethodChannel
import com.unilog.uniges.R  
class TransparentActivity : AppCompatActivity() {
    private lateinit var titreEditText: EditText
    private lateinit var descriptionEditText: EditText
    private lateinit var statuEditText: EditText
    private lateinit var dureeEstimeeEditText: EditText
    private lateinit var dateRealisationEditText: EditText
    private lateinit var dureeRealisationEditText: EditText
    private lateinit var prioriteEditText: EditText
    private lateinit var rankEditText: EditText
    private lateinit var dateEcheanceEditText: EditText
    private lateinit var methodChannel: MethodChannel
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.activity_transparent)
    Log.d("TransparentActivity", "La classe TransparentActivity est ouverte")

   val flutterEngine = FlutterEngineCache.getInstance().get("default")

if (flutterEngine != null) {
    Log.d("FlutterEngine", "Le moteur Flutter a été récupéré avec succès.")
    
    val dartExecutor = flutterEngine.dartExecutor
    if (dartExecutor != null) {
        Log.d("DartExecutor", "Le dartExecutor a été récupéré avec succès.")
        
        val binaryMessenger = dartExecutor.binaryMessenger
        if (binaryMessenger != null) {
            Log.d("BinaryMessenger", "Le binaryMessenger a été récupéré avec succès.")
            
            // Initialisez le canal de méthode
            methodChannel = MethodChannel(binaryMessenger, "com.example.channelName")
        } else {
            Log.e("TransparentActivity", "Erreur lors de la récupération du binaryMessenger : binaryMessenger est null.")
        }
    } else {
        Log.e("TransparentActivity", "Erreur lors de la récupération du dartExecutor : dartExecutor est null.")
    }
} else {
    Log.e("TransparentActivity", "Erreur lors de la récupération du moteur Flutter : flutterEngine est null.")
}



    titreEditText = findViewById(R.id.editTextName)
    descriptionEditText = findViewById(R.id.editTextDescription)
    statuEditText = findViewById(R.id.editTextStatu)
    dureeEstimeeEditText = findViewById(R.id.editTextDureeEstimee)
    dateRealisationEditText = findViewById(R.id.editTextDateRealisation)
    dureeRealisationEditText = findViewById(R.id.editTextDureeRealisation)
    prioriteEditText = findViewById(R.id.editTextPriorite)
    rankEditText = findViewById(R.id.editTextRank)
    dateEcheanceEditText = findViewById(R.id.editTextDateEcheance)

    // Récupérez votre ScrollView défini dans votre layout XML
    val scrollView = findViewById<NestedScrollView>(R.id.scrollView)

    if (scrollView != null) {
        scrollView.isFillViewport = true
        // Autres opérations utilisant scrollView
    } else {
        Log.e("TransparentActivity", "scrollView is null")
        // Gérer le cas où scrollView est null, par exemple afficher un message d'erreur ou effectuer une autre action appropriée.
    }

    // Ajoutez un gestionnaire de clic pour le bouton d'enregistrement
    val saveButton = findViewById<Button>(R.id.saveButton)
    saveButton.setOnClickListener {
        Log.d("TransparentActivity", "Le bouton Save a été cliqué")

        // Remplissez les champs avant d'appeler la méthode _save dans Dart
        val titre = titreEditText.text.toString()
        val description = descriptionEditText.text.toString()
        val statu = statuEditText.text.toString()
        val dureeEstimee = dureeEstimeeEditText.text.toString()
        val dateRealisation = dateRealisationEditText.text.toString()
        val dureeRealisation = dureeRealisationEditText.text.toString()
        val priorite = prioriteEditText.text.toString()
        val rank = rankEditText.text.toString()
        val dateEcheance = dateEcheanceEditText.text.toString()

        Log.d("TransparentActivity", "Valeurs extraites des champs : Titre=$titre, Description=$description, Statut=$statu, Durée estimée=$dureeEstimee, Date de réalisation=$dateRealisation, Durée de réalisation=$dureeRealisation, Priorité=$priorite, Rank=$rank, Date d'échéance=$dateEcheance")

        // Appelez la méthode _save dans Dart en passant les valeurs des champs
        callSaveMethod(titre, description, statu, dureeEstimee, dateRealisation, dureeRealisation, priorite, rank, dateEcheance)
    }
}
private fun callSaveMethod(titre: String, description: String, statu: String, dureeEstimee: String, dateRealisation: String, dureeRealisation: String, priorite: String, rank: String, dateEcheance: String) {
    Log.d("TransparentActivity", "Appel de la méthode _save dans Dart avec les paramètres suivants : Titre=$titre, Description=$description, Statut=$statu, Durée estimée=$dureeEstimee, Date de réalisation=$dateRealisation, Durée de réalisation=$dureeRealisation, Priorité=$priorite, Rank=$rank, Date d'échéance=$dateEcheance")
    
    val args = mapOf(
        "titre" to titre,
        "description" to description,
        "statu" to statu,
        "dureeEstimee" to dureeEstimee,
        "dateRealisation" to dateRealisation,
        "dureeRealisation" to dureeRealisation,
        "priorite" to priorite,
        "rank" to rank,
        "dateEcheance" to dateEcheance
    )

    // Appelez la méthode _save dans Dart
    val result =  methodChannel.invokeMethod("_save1", args)
// Imprimez le résultat
Log.d("TransparentActivity", "Résultat de l'appel à la méthode _save1 : $result")

    // Vérifiez si l'enregistrement a réussi
    val isSaved = result 

    if (isSaved != null ) {
        // Si l'enregistrement réussit, affichez un message de confirmation et retournez à l'activité principale
        Log.d("TransparentActivity", "Confirmation envoyée à Flutter : $result")
          Toast.makeText(this, "Tâche ajoutée avec succès !", Toast.LENGTH_SHORT).show()
        // Vous pouvez également ajouter une logique pour notifier Flutter du succès de l'enregistrement ici.
        // Si l'enregistrement est réussi, retournez à l'activité principale
        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
        finish()
    } else {
        // Si l'enregistrement échoue, affichez un message d'erreur
        Log.e("TransparentActivity", "Aucun résultat reçu de Flutter après l'appel de la méthode _save")
    }
}

}