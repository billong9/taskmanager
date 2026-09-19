import type { TaskStatus } from '../types/model'

const config: Record<TaskStatus, { label: string; classes: string }> = {
  TODO: { label: 'À faire', classes: 'bg-gray-100 text-gray-700 border-gray-300' },
  IN_PROGRESS: { label: 'En cours', classes: 'bg-amber-50 text-amber-700 border-amber-300' },
  DONE: { label: 'Terminée', classes: 'bg-green-50 text-green-700 border-green-300' },
}

export default function StatusBadge({ status }: { status: TaskStatus }) {
  const { label, classes } = config[status]
  return (
    <span className={`inline-block rounded-full border px-2.5 py-0.5 text-xs font-medium ${classes}`}>
      {label}
    </span>
  )
}
