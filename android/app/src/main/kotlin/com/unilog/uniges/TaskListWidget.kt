package com.unilog.uniges
import android.text.style.RelativeSizeSpan
import com.unilog.uniges.TransparentActivity
import android.graphics.Typeface
import android.text.style.StyleSpan
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.app.PendingIntent
import android.graphics.Color
import android.text.SpannableStringBuilder
import android.text.style.ForegroundColorSpan
import com.unilog.uniges.R
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class TaskListWidget : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Récupérer les tâches depuis les préférences partagées
                val tasksJson = widgetData.getString("kanban_tasks", "[]")

                // Convertir la chaîne JSON en une liste de tâches
                val tasksArray = JSONArray(tasksJson)
                val taskMap = mutableMapOf<String, MutableList<String>>() // Utiliser un map pour regrouper les tâches par date

                for (i in 0 until tasksArray.length()) {
                    val taskObj = tasksArray.getJSONObject(i)
                    val taskTitle = taskObj.optString("Titre") // Utiliser optString pour obtenir une chaîne vide si le titre est nul
                    val taskDate = taskObj.getString("DateEcheance")

                    // Ajouter la tâche au groupe correspondant à sa date, si le titre n'est pas nul
                    if (!taskTitle.isNullOrEmpty()) {
                        if (!taskMap.containsKey(taskDate)) {
                            taskMap[taskDate] = mutableListOf()
                        }
                        taskMap[taskDate]?.add(taskTitle)
                    }
                }

         // Créer le texte à afficher en combinant les titres des tâches avec la même date
val combinedTasksText = SpannableStringBuilder()
taskMap.entries.forEach { (date, taskList) ->
   val dateSpannable = SpannableStringBuilder(date).apply {
    setSpan(ForegroundColorSpan(Color.GRAY), 0, length, SpannableStringBuilder.SPAN_EXCLUSIVE_EXCLUSIVE)
    // Définir une taille de texte relative pour la date (par exemple, 1.2f pour 20% de plus que la taille de texte normale)
    setSpan(RelativeSizeSpan(1.2f), 0, length, SpannableStringBuilder.SPAN_EXCLUSIVE_EXCLUSIVE)
}

    combinedTasksText.append(dateSpannable)
    combinedTasksText.append(":\n") 
    taskList.forEach { taskTitle ->
        // Ajouter un point gras avant chaque titre de tâche avec une couleur spécifique
        val titleSpannable = SpannableStringBuilder("• ").apply {
            setSpan(ForegroundColorSpan(Color.RED), 0, length, SpannableStringBuilder.SPAN_EXCLUSIVE_EXCLUSIVE)
            setSpan(StyleSpan(Typeface.BOLD), 0, length, SpannableStringBuilder.SPAN_EXCLUSIVE_EXCLUSIVE)
        }
        combinedTasksText.append(titleSpannable)
        combinedTasksText.append(taskTitle)
        combinedTasksText.append("\n") 
    }
    
}

// Mettre à jour le texte dans le widget
setTextViewText(R.id.task_list_text, combinedTasksText)

             setTextViewText(R.id.task_list_text, combinedTasksText)
               val openTransparentActivityIntent = Intent(context, TransparentActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(context, 0, openTransparentActivityIntent, PendingIntent.FLAG_UPDATE_CURRENT)
                
                // Appliquer le PendingIntent au bouton dans le widget
                setOnClickPendingIntent(R.id.add_button, pendingIntent)


                
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
