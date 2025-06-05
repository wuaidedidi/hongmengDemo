export interface FocusTimerParams {
  title: string;
  taskTitle: string;
  time: number;
  isSequence?: boolean;
  collectionId?: string;
  subTaskId?: string;
  currentSubTaskIndex?: number;
  totalSubTasksInCollection?: number;
} 