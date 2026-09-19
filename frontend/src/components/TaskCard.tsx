import type { Task } from '../types/model'
import StatusBadge from './StatusBadge'

interface TaskCardProps {
  task: Task
  onEdit: (task: Task) => void
  onDelete: (task: Task) => void
}

export default function TaskCard({ task, onEdit, onDelete }: TaskCardProps) {
  const formattedDate = new Date(task.updatedAt).toLocaleDateString('fr-FR', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  })

  return (
    <div className="flex flex-col gap-2 rounded-xl border border-gray-200 bg-white p-4 shadow-sm transition hover:shadow-md">
      <div className="flex items-start justify-between gap-2">
        <h3 className="font-semibold text-gray-900">{task.title}</h3>
        <StatusBadge status={task.status} />
      </div>

      {task.description && (
        <p className="text-sm text-gray-600 line-clamp-3">{task.description}</p>
      )}

      <div className="mt-2 flex items-center justify-between">
        <span className="text-xs text-gray-400">Mis à jour le {formattedDate}</span>
        <div className="flex gap-2">
          <button
            onClick={() => onEdit(task)}
            className="rounded-md px-2 py-1 text-xs font-medium text-brand-600 hover:bg-brand-50"
          >
            Modifier
          </button>
          <button
            onClick={() => onDelete(task)}
            className="rounded-md px-2 py-1 text-xs font-medium text-red-600 hover:bg-red-50"
          >
            Supprimer
          </button>
        </div>
      </div>
    </div>
  )
}
