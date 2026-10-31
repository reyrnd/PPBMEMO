/*
 * Prototipe React tersimpan sebagai referensi visual; aplikasi berjalan di Flutter.
import {
  createElement,
  useRef,
  useState,
  type ButtonHTMLAttributes,
  type InputHTMLAttributes,
  type ReactNode,
} from "react";
import {
  ArrowLeft,
  Bell,
  Bold,
  BookOpen,
  CalendarDays,
  Check,
  CheckCircle2,
  ChevronRight,
  Clock3,
  Copy,
  File,
  FileText,
  Folder,
  Globe2,
  GripVertical,
  Hand,
  Home,
  Image,
  Italic,
  LayoutGrid,
  ListFilter,
  List,
  Link2,
  LogIn,
  MessageCircle,
  Minus,
  MoreHorizontal,
  Paperclip,
  Pencil,
  Plus,
  RefreshCw,
  Reply,
  Save,
  Search,
  Settings,
  Send,
  Sparkles,
  Trash2,
  UserRound,
  Users,
  Video,
  X,
  Zap,
  type LucideIcon,
} from "lucide-react";

type Tab = "home" | "library" | "workspace" | "profile";
type ScreenKind =
  | "search"
  | "memo"
  | "collection"
  | "asset"
  | "activity"
  | "members"
  | "task"
  | "canvas-note"
  | "profile"
  | "settings"
  | "help"
  | "upgrade"
  | "stats"
  | "workspace-detail";
type Screen = { kind: ScreenKind; title: string; subtitle?: string; workspaceId?: string };
type SheetKind =
  | "notifications"
  | "home-menu"
  | "create-workspace"
  | "workspace-choice"
  | "join-workspace"
  | "library-filter"
  | "edit-collections"
  | "sort"
  | "invite"
  | "new-card"
  | "canvas-tools"
  | "edit-profile"
  | "notification-settings"
  | "language"
  | "memo-actions"
  | "upgrade"
  | "support"
  | "asset-actions";
type Navigate = (screen: Screen) => void;
type OpenSheet = (sheet: SheetKind) => void;
type DeadlineStatus = "upcoming" | "today" | "overdue" | "completed";
type MemberTone = "dark" | "sand" | "olive" | "cream";
type WorkspaceMember = {
  id: string;
  name: string;
  initials: string;
  role: "Owner" | "Member";
  tone: MemberTone;
  status: string;
};
type Workspace = {
  id: string;
  name: string;
  description: string;
  code: string;
  currentUserRole: "Owner" | "Member";
  memos: number;
  activeTasks: number;
  completedTasks: number;
  members: WorkspaceMember[];
  updated: string;
};

const initialWorkspaces: Workspace[] = [
  {
    id: "northstar",
    name: "Northstar Studio",
    description: "Product strategy, research, and launch planning.",
    code: "NORTH-24Q",
    currentUserRole: "Owner",
    memos: 26,
    activeTasks: 11,
    completedTasks: 42,
    updated: "12 min ago",
    members: [
      { id: "naya", name: "Naya Anindita", initials: "NA", role: "Owner", tone: "dark", status: "You" },
      { id: "ardi", name: "Ardi Rahman", initials: "AR", role: "Member", tone: "sand", status: "Active now" },
      { id: "jade", name: "Jade Diaz", initials: "JD", role: "Member", tone: "olive", status: "Active 1h ago" },
      { id: "raka", name: "Raka Putra", initials: "RP", role: "Member", tone: "cream", status: "Active yesterday" },
    ],
  },
  {
    id: "weekend-lab",
    name: "Weekend Lab",
    description: "A small space for experiments and side projects.",
    code: "LAB-7K2P",
    currentUserRole: "Member",
    memos: 14,
    activeTasks: 5,
    completedTasks: 19,
    updated: "Yesterday",
    members: [
      { id: "maya", name: "Maya Chen", initials: "MC", role: "Owner", tone: "olive", status: "Active now" },
      { id: "naya", name: "Naya Anindita", initials: "NA", role: "Member", tone: "dark", status: "You" },
      { id: "leo", name: "Leo Martin", initials: "LM", role: "Member", tone: "sand", status: "Active 3h ago" },
    ],
  },
];

const joinableWorkspaces: Record<string, Workspace> = {
  "DESIGN-42": {
    id: "design-circle",
    name: "Design Circle",
    description: "Weekly critiques, references, and community resources.",
    code: "DESIGN-42",
    currentUserRole: "Member",
    memos: 31,
    activeTasks: 7,
    completedTasks: 54,
    updated: "Just joined",
    members: [
      { id: "sora", name: "Sora Kim", initials: "SK", role: "Owner", tone: "olive", status: "Active now" },
      { id: "ravi", name: "Ravi Shah", initials: "RS", role: "Member", tone: "sand", status: "Active 20m ago" },
      { id: "naya", name: "Naya Anindita", initials: "NA", role: "Member", tone: "dark", status: "You" },
    ],
  },
  "SPRINT-88": {
    id: "brand-sprint",
    name: "Brand Sprint",
    description: "A focused workspace for the upcoming brand refresh.",
    code: "SPRINT-88",
    currentUserRole: "Member",
    memos: 18,
    activeTasks: 9,
    completedTasks: 23,
    updated: "Just joined",
    members: [
      { id: "raka", name: "Raka Putra", initials: "RP", role: "Owner", tone: "cream", status: "Active now" },
      { id: "naya", name: "Naya Anindita", initials: "NA", role: "Member", tone: "dark", status: "You" },
    ],
  },
};

function getDeadlineStatus(date: string, completed = false): DeadlineStatus {
  if (completed) return "completed";
  const due = new Date(`${date}T23:59:59`);
  const today = new Date();
  const startToday = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  const startDue = new Date(due.getFullYear(), due.getMonth(), due.getDate());
  const dayDifference = Math.round((startDue.getTime() - startToday.getTime()) / 86400000);
  if (dayDifference < 0) return "overdue";
  if (dayDifference === 0) return "today";
  return "upcoming";
}

function formatDeadline(date: string) {
  return new Intl.DateTimeFormat("en", { month: "short", day: "numeric" }).format(new Date(`${date}T12:00:00`));
}

function dateOffset(days: number) {
  const date = new Date();
  date.setDate(date.getDate() + days);
  return date.toISOString().slice(0, 10);
}

function DeadlineBadge({ date, completed = false, onClick }: { date: string; completed?: boolean; onClick?: () => void }) {
  const status = getDeadlineStatus(date, completed);
  const styles = {
    upcoming: "bg-peach text-caramel",
    today: "bg-caramel text-white",
    overdue: "bg-danger-soft text-danger",
    completed: "bg-mint text-olive",
  };
  const label = status === "today" ? "Due today" : status === "overdue" ? `Overdue · ${formatDeadline(date)}` : status === "completed" ? "Completed" : `Due ${formatDeadline(date)}`;
  const content = <><CalendarDays size={11} /> {label}</>;
  return onClick ? (
    <Button onClick={onClick} className={`flex items-center gap-1 rounded-full px-2 py-1 text-[8px] font-bold ${styles[status]}`}>{content}</Button>
  ) : (
    <span className={`inline-flex items-center gap-1 rounded-full px-2 py-1 text-[8px] font-bold ${styles[status]}`}>{content}</span>
  );
}

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  children: ReactNode;
};

function Button({ children, className = "", ...props }: ButtonProps) {
  return createElement(
    "button",
    {
      ...props,
      className: `cursor-pointer border-0 bg-transparent font-inherit ${className}`,
    },
    children,
  );
}

function Input({ className = "", ...props }: InputHTMLAttributes<HTMLInputElement>) {
  return createElement("input", {
    ...props,
    className: `w-full border-0 bg-transparent font-inherit outline-none ${className}`,
  });
}

function Avatar({
  initials,
  tone = "dark",
  className = "",
}: {
  initials: string;
  tone?: "dark" | "sand" | "olive" | "cream";
  className?: string;
}) {
  const tones = {
    dark: "bg-ink text-white",
    sand: "bg-caramel text-white",
    olive: "bg-olive text-white",
    cream: "bg-soft text-muted",
  };
  return (
    <div
      className={`flex shrink-0 items-center justify-center rounded-full text-[11px] font-bold ring-2 ring-white ${tones[tone]} ${className}`}
    >
      {initials}
    </div>
  );
}

function SectionTitle({ title, action, onAction }: { title: string; action?: string; onAction?: () => void }) {
  return (
    <div className="mb-3 flex items-center justify-between">
      <div className="text-[17px] font-bold tracking-[-0.02em] text-ink">{title}</div>
      {action && (
        <Button onClick={onAction} className="flex items-center gap-0.5 rounded-full px-2 py-1 text-xs font-semibold text-muted hover:bg-soft">
          {action}
          <ChevronRight size={14} strokeWidth={2.2} />
        </Button>
      )}
    </div>
  );
}

function Header({
  title,
  subtitle,
  onNotify,
  onSearch,
}: {
  title: string;
  subtitle?: string;
  onNotify: () => void;
  onSearch: () => void;
}) {
  return (
    <div className="flex items-center justify-between px-5 pb-5 pt-4">
      <div>
        <div className="text-[11px] font-bold uppercase tracking-[0.16em] text-muted">
          {subtitle || "Memospace"}
        </div>
        <div className="mt-0.5 text-[27px] font-extrabold tracking-[-0.04em] text-ink">{title}</div>
      </div>
      <div className="flex items-center gap-2">
        <Button
          aria-label="Search"
          onClick={onSearch}
          className="flex size-10 items-center justify-center rounded-full bg-white text-ink shadow-soft transition hover:-translate-y-0.5"
        >
          <Search size={19} strokeWidth={2.2} />
        </Button>
        <Button
          aria-label="Notifications"
          onClick={onNotify}
          className="relative flex size-10 items-center justify-center rounded-full bg-white text-ink shadow-soft transition hover:-translate-y-0.5"
        >
          <Bell size={19} strokeWidth={2.2} />
          <span className="absolute right-2.5 top-2 size-1.5 rounded-full bg-caramel ring-2 ring-white" />
        </Button>
      </div>
    </div>
  );
}

function HomePage({
  onNotify,
  navigate,
  openSheet,
  switchTab,
}: {
  onNotify: () => void;
  navigate: Navigate;
  openSheet: OpenSheet;
  switchTab: (tab: Tab) => void;
}) {
  return (
    <>
      <Header
        title="Good morning, Naya"
        onNotify={onNotify}
        onSearch={() => navigate({ kind: "search", title: "Search MemoSpace", subtitle: "Memos, files & people" })}
      />
      <div className="space-y-6 px-5 pb-32">
        <div className="relative overflow-hidden rounded-[28px] bg-ink p-5 text-white shadow-card">
          <div className="absolute -right-7 -top-8 size-32 rounded-full border border-white/10" />
          <div className="absolute -right-2 top-7 size-16 rounded-full border border-white/10" />
          <div className="relative">
            <div className="flex items-center justify-between">
              <div className="inline-flex items-center gap-1.5 rounded-full bg-white/10 px-2.5 py-1 text-[10px] font-bold uppercase tracking-[0.12em] text-white/80">
                <Sparkles size={12} />
                Your space
              </div>
              <Button
                aria-label="Space actions"
                onClick={() => openSheet("home-menu")}
                className="flex size-8 items-center justify-center rounded-full text-white/50 hover:bg-white/10"
              >
                <MoreHorizontal size={20} />
              </Button>
            </div>
            <div className="mt-5 max-w-[250px] text-[23px] font-bold leading-[1.15] tracking-[-0.035em]">
              Turn your ideas into something real.
            </div>
            <div className="mt-2 text-xs leading-5 text-white/55">12 memos · 4 shared this week</div>
            <Button
              onClick={() => navigate({ kind: "memo", title: "Untitled memo", subtitle: "Personal" })}
              className="mt-5 flex items-center gap-2 rounded-full bg-white px-4 py-2.5 text-xs font-bold text-ink transition hover:bg-canvas"
            >
              <Plus size={15} strokeWidth={2.5} />
              New memo
            </Button>
          </div>
        </div>

        <div>
          <SectionTitle title="Quick actions" />
          <div className="grid grid-cols-3 gap-2.5">
            {[
              { icon: FileText, label: "Note", color: "bg-peach" },
              { icon: CheckCircle2, label: "Checklist", color: "bg-lilac" },
              { icon: Users, label: "Workspace", color: "bg-mint" },
            ].map(({ icon: Icon, label, color }) => (
              <Button
                key={label}
                onClick={() =>
                  label === "Workspace"
                    ? openSheet("workspace-choice")
                    : navigate({
                        kind: "memo",
                        title: label === "Checklist" ? "New checklist" : "Untitled memo",
                        subtitle: "Personal",
                      })
                }
                className="group rounded-2xl bg-white p-3 text-left shadow-soft transition hover:-translate-y-0.5"
              >
                <div className={`flex size-9 items-center justify-center rounded-xl ${color} text-ink`}>
                  <Icon size={17} strokeWidth={2.1} />
                </div>
                <div className="mt-3 text-xs font-bold text-ink">{label}</div>
              </Button>
            ))}
          </div>
        </div>

        <div>
          <SectionTitle title="Recent memos" action="See all" onAction={() => switchTab("library")} />
          <div className="space-y-2.5">
            <MemoCard
              icon={Zap}
              iconStyle="bg-peach text-caramel"
              title="Product ideas"
              preview="A place for the sparks that might become our next big thing..."
              meta="Edited 18 min ago"
              tag="Personal"
              dueDate={dateOffset(2)}
              onClick={() => navigate({ kind: "memo", title: "Product ideas", subtitle: "Personal · Edited 18 min ago" })}
            />
            <MemoCard
              icon={CheckCircle2}
              iconStyle="bg-mint text-olive"
              title="Launch checklist"
              preview="Polish onboarding · Review website copy · Final QA"
              meta="Edited yesterday"
              tag="Studio"
              progress={68}
              dueDate={dateOffset(0)}
              onClick={() => navigate({ kind: "memo", title: "Launch checklist", subtitle: "Northstar Studio" })}
            />
            <MemoCard
              icon={BookOpen}
              iconStyle="bg-lilac text-plum"
              title="Research notes"
              preview="Key takeaways from our conversations with early users."
              meta="Monday"
              tag="Product"
              dueDate={dateOffset(-1)}
              onClick={() => navigate({ kind: "memo", title: "Research notes", subtitle: "Product" })}
            />
          </div>
        </div>

        <div>
          <SectionTitle title="Your workspaces" action="Manage" onAction={() => switchTab("workspace")} />
          <Button onClick={() => switchTab("workspace")} className="w-full rounded-[24px] bg-white p-4 text-left shadow-soft">
            <div className="flex items-center gap-3">
              <div className="flex size-11 items-center justify-center rounded-2xl bg-ink text-white">
                <LayoutGrid size={19} />
              </div>
              <div className="min-w-0 flex-1">
                <div className="text-sm font-bold text-ink">Northstar Studio</div>
                <div className="mt-0.5 text-[11px] text-muted">8 members · 26 memos</div>
              </div>
              <div className="flex -space-x-1.5">
                <Avatar initials="NA" className="size-7" />
                <Avatar initials="AR" tone="sand" className="size-7" />
                <Avatar initials="JD" tone="olive" className="size-7" />
              </div>
            </div>
            <div className="mt-4 grid grid-cols-3 divide-x divide-line rounded-2xl bg-surface py-3 text-center">
              <Stat value="7" label="To do" />
              <Stat value="4" label="Working" />
              <Stat value="12" label="Done" />
            </div>
          </Button>
        </div>

        <div>
          <SectionTitle
            title="Latest activity"
            action="View all"
            onAction={() => navigate({ kind: "activity", title: "Team activity", subtitle: "Northstar Studio" })}
          />
          <div className="space-y-4 rounded-[24px] bg-white p-4 shadow-soft">
            <Activity
              avatar="AR"
              tone="sand"
              name="Ardi"
              text="mentioned you in"
              subject="Visual direction"
              time="8m"
              onClick={() => navigate({ kind: "memo", title: "Visual direction", subtitle: "Comment from Ardi" })}
            />
            <Activity
              avatar="JD"
              tone="olive"
              name="Jade"
              text="completed"
              subject="Review onboarding"
              time="1h"
              onClick={() => navigate({ kind: "task", title: "Review onboarding", subtitle: "Completed by Jade" })}
            />
          </div>
        </div>
      </div>
    </>
  );
}

function MemoCard({
  icon: Icon,
  iconStyle,
  title,
  preview,
  meta,
  tag,
  progress,
  dueDate,
  onClick,
}: {
  icon: LucideIcon;
  iconStyle: string;
  title: string;
  preview: string;
  meta: string;
  tag: string;
  progress?: number;
  dueDate?: string;
  onClick: () => void;
}) {
  return (
    <Button onClick={onClick} className="flex w-full gap-3 rounded-[22px] bg-white p-3.5 text-left shadow-soft transition hover:-translate-y-0.5">
      <div className={`flex size-10 shrink-0 items-center justify-center rounded-2xl ${iconStyle}`}>
        <Icon size={18} />
      </div>
      <div className="min-w-0 flex-1">
        <div className="flex items-start justify-between gap-2">
          <div className="text-sm font-bold text-ink">{title}</div>
          <MoreHorizontal size={17} className="shrink-0 text-faint" />
        </div>
        <div className="mt-1 line-clamp-2 text-[11px] leading-[1.55] text-muted">{preview}</div>
        {progress && (
          <div className="mt-2 h-1 overflow-hidden rounded-full bg-soft">
            <div className="h-full rounded-full bg-olive" style={{ width: `${progress}%` }} />
          </div>
        )}
        <div className="mt-2.5 flex items-center gap-2 text-[10px] font-medium text-faint">
          <span>{meta}</span>
          <span>•</span>
          <span className="rounded-full bg-surface px-2 py-0.5 text-muted">{tag}</span>
          {dueDate && <span className="ml-auto"><DeadlineBadge date={dueDate} /></span>}
        </div>
      </div>
    </Button>
  );
}

function Stat({ value, label }: { value: string; label: string }) {
  return (
    <div>
      <div className="text-sm font-extrabold text-ink">{value}</div>
      <div className="mt-0.5 text-[9px] font-semibold uppercase tracking-wider text-faint">{label}</div>
    </div>
  );
}

function Activity({
  avatar,
  tone,
  name,
  text,
  subject,
  time,
  onClick,
}: {
  avatar: string;
  tone: "sand" | "olive";
  name: string;
  text: string;
  subject: string;
  time: string;
  onClick: () => void;
}) {
  return (
    <Button onClick={onClick} className="flex w-full gap-3 text-left">
      <Avatar initials={avatar} tone={tone} className="size-8" />
      <div className="min-w-0 flex-1 text-xs leading-5 text-muted">
        <span className="font-bold text-ink">{name}</span> {text}{" "}
        <span className="font-semibold text-ink">{subject}</span>
      </div>
      <div className="text-[10px] text-faint">{time}</div>
    </Button>
  );
}

function LibraryPage({
  onNotify,
  navigate,
  openSheet,
}: {
  onNotify: () => void;
  navigate: Navigate;
  openSheet: OpenSheet;
}) {
  const [filter, setFilter] = useState("All");
  const filters = ["All", "Notes", "Media", "Files"];
  return (
    <>
      <Header
        title="Your library"
        subtitle="Everything, organized"
        onNotify={onNotify}
        onSearch={() => navigate({ kind: "search", title: "Search library", subtitle: "Notes, media & files" })}
      />
      <div className="px-5 pb-32">
        <div className="flex items-center gap-2 rounded-2xl bg-white px-4 py-3 shadow-soft">
          <Button
            onClick={() => navigate({ kind: "search", title: "Search library", subtitle: "Notes, media & files" })}
            className="flex flex-1 items-center gap-2 text-left"
          >
            <Search size={17} className="text-faint" />
            <span className="text-xs text-faint">Search your memos</span>
          </Button>
          <Button
            aria-label="Filter library"
            onClick={() => openSheet("library-filter")}
            className="flex size-7 items-center justify-center rounded-full text-muted hover:bg-soft"
          >
            <ListFilter size={17} />
          </Button>
        </div>
        <div className="mt-4 flex gap-2 overflow-x-auto pb-2 scrollbar-none">
          {filters.map((item) => (
            <Button
              key={item}
              onClick={() => setFilter(item)}
              className={`shrink-0 rounded-full px-4 py-2 text-xs font-bold transition ${
                filter === item ? "bg-ink text-white" : "bg-white text-muted"
              }`}
            >
              {item}
            </Button>
          ))}
        </div>
        <div className="mt-6">
          <SectionTitle title="Collections" action="Edit" onAction={() => openSheet("edit-collections")} />
          <div className="grid grid-cols-2 gap-3">
            <Collection title="Ideas" count="14 items" icon={Sparkles} color="bg-peach" onClick={() => navigate({ kind: "collection", title: "Ideas", subtitle: "14 items" })} />
            <Collection title="Projects" count="8 items" icon={Folder} color="bg-mint" onClick={() => navigate({ kind: "collection", title: "Projects", subtitle: "8 items" })} />
            <Collection title="Reading" count="21 items" icon={BookOpen} color="bg-lilac" onClick={() => navigate({ kind: "collection", title: "Reading", subtitle: "21 items" })} />
            <Collection title="Archive" count="36 items" icon={File} color="bg-soft" onClick={() => navigate({ kind: "collection", title: "Archive", subtitle: "36 items" })} />
          </div>
        </div>
        <div className="mt-7">
          <SectionTitle title="Recently added" action="Sort" onAction={() => openSheet("sort")} />
          <div className="space-y-2.5">
            <LibraryRow icon={FileText} title="Product brief v2" type="Note" meta="Today, 9:42 AM" dueDate={dateOffset(3)} onClick={() => navigate({ kind: "memo", title: "Product brief v2", subtitle: "Edited today" })} />
            <LibraryRow icon={Image} title="Moodboard references" type="12 photos" meta="Yesterday" onClick={() => navigate({ kind: "asset", title: "Moodboard references", subtitle: "12 photos" })} />
            <LibraryRow icon={Video} title="User interview — Maya" type="Video · 18:24" meta="May 24" onClick={() => navigate({ kind: "asset", title: "User interview — Maya", subtitle: "Video · 18:24" })} />
            <LibraryRow icon={File} title="Brand Guidelines.pdf" type="PDF · 4.8 MB" meta="May 22" onClick={() => navigate({ kind: "asset", title: "Brand Guidelines.pdf", subtitle: "PDF · 4.8 MB" })} />
          </div>
        </div>
      </div>
    </>
  );
}

function Collection({ title, count, icon: Icon, color, onClick }: { title: string; count: string; icon: LucideIcon; color: string; onClick: () => void }) {
  return (
    <Button onClick={onClick} className="rounded-[22px] bg-white p-4 text-left shadow-soft transition hover:-translate-y-0.5">
      <div className={`flex size-10 items-center justify-center rounded-2xl ${color} text-ink`}>
        <Icon size={18} />
      </div>
      <div className="mt-5 text-sm font-bold text-ink">{title}</div>
      <div className="mt-1 text-[10px] text-faint">{count}</div>
    </Button>
  );
}

function LibraryRow({ icon: Icon, title, type, meta, dueDate, onClick }: { icon: LucideIcon; title: string; type: string; meta: string; dueDate?: string; onClick: () => void }) {
  return (
    <Button onClick={onClick} className="flex w-full items-center gap-3 rounded-2xl bg-white p-3 text-left shadow-soft">
      <div className="flex size-10 items-center justify-center rounded-xl bg-surface text-muted">
        <Icon size={18} />
      </div>
      <div className="min-w-0 flex-1">
        <div className="truncate text-xs font-bold text-ink">{title}</div>
        <div className="mt-1 text-[10px] text-faint">{type} · {meta}</div>
      </div>
      {dueDate && <DeadlineBadge date={dueDate} />}
      <MoreHorizontal size={17} className="text-faint" />
    </Button>
  );
}

function WorkspacePage({
  onNotify,
  navigate,
  openSheet,
  workspaces,
}: {
  onNotify: () => void;
  navigate: Navigate;
  openSheet: OpenSheet;
  workspaces: Workspace[];
}) {
  const totalMembers = workspaces.reduce((total, workspace) => total + workspace.members.length, 0);
  return (
    <>
      <Header
        title="Your workspaces"
        subtitle={`${workspaces.length} active spaces`}
        onNotify={onNotify}
        onSearch={() => navigate({ kind: "search", title: "Search workspaces", subtitle: "Teams, memos & members" })}
      />
      <div className="px-5 pb-32">
        <div className="grid grid-cols-2 gap-3">
          <Button
            onClick={() => openSheet("create-workspace")}
            className="flex items-center gap-3 rounded-[22px] bg-ink p-4 text-left text-white shadow-card"
          >
            <span className="flex size-9 items-center justify-center rounded-xl bg-white/10">
              <Plus size={17} />
            </span>
            <span>
              <span className="block text-xs font-bold">Create</span>
              <span className="mt-0.5 block text-[9px] text-white/50">New workspace</span>
            </span>
          </Button>
          <Button
            onClick={() => openSheet("join-workspace")}
            className="flex items-center gap-3 rounded-[22px] bg-white p-4 text-left shadow-soft"
          >
            <span className="flex size-9 items-center justify-center rounded-xl bg-mint text-olive">
              <LogIn size={17} />
            </span>
            <span>
              <span className="block text-xs font-bold text-ink">Join</span>
              <span className="mt-0.5 block text-[9px] text-faint">Use invite code</span>
            </span>
          </Button>
        </div>

        <div className="mt-5 grid grid-cols-3 divide-x divide-line rounded-[22px] bg-white py-4 shadow-soft">
          <Stat value={`${workspaces.length}`} label="Spaces" />
          <Stat value={`${totalMembers}`} label="Members" />
          <Stat value={`${workspaces.reduce((total, workspace) => total + workspace.memos, 0)}`} label="Memos" />
        </div>

        <div className="mt-7">
          <SectionTitle title="All workspaces" />
          <div className="space-y-3">
            {workspaces.map((workspace, index) => (
              <Button
                key={workspace.id}
                onClick={() =>
                  navigate({
                    kind: "workspace-detail",
                    title: workspace.name,
                    subtitle: workspace.description,
                    workspaceId: workspace.id,
                  })
                }
                className="w-full rounded-[24px] bg-white p-4 text-left shadow-soft transition hover:-translate-y-0.5"
              >
                <div className="flex items-start gap-3">
                  <div className={`flex size-11 shrink-0 items-center justify-center rounded-2xl ${index % 2 ? "bg-mint text-olive" : "bg-ink text-white"}`}>
                    <LayoutGrid size={19} />
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2">
                      <span className="truncate text-sm font-bold text-ink">{workspace.name}</span>
                      <span className="rounded-full bg-surface px-2 py-0.5 text-[8px] font-bold uppercase tracking-wider text-muted">
                        {workspace.currentUserRole}
                      </span>
                    </div>
                    <div className="mt-1 line-clamp-1 text-[10px] text-faint">{workspace.description}</div>
                  </div>
                  <ChevronRight size={16} className="mt-1 shrink-0 text-faint" />
                </div>
                <div className="mt-4 flex items-center border-t border-line pt-3">
                  <div className="flex -space-x-1.5">
                    {workspace.members.slice(0, 3).map((member) => (
                      <Avatar key={member.id} initials={member.initials} tone={member.tone} className="size-7" />
                    ))}
                  </div>
                  <span className="ml-2 text-[9px] font-semibold text-muted">{workspace.members.length} members</span>
                  <span className="ml-auto text-[9px] text-faint">Updated {workspace.updated}</span>
                </div>
              </Button>
            ))}
          </div>
        </div>
      </div>
    </>
  );
}

function WorkspaceDetailScreen({
  workspace,
  onBack,
  navigate,
  openSheet,
  onInvite,
}: {
  workspace: Workspace;
  onBack: () => void;
  navigate: Navigate;
  openSheet: OpenSheet;
  onInvite: () => void;
}) {
  const [section, setSection] = useState<"Overview" | "Hybrid Board">("Overview");
  const [boardView, setBoardView] = useState<"Kanban" | "Canvas">("Kanban");
  return (
    <div className="min-h-full pb-10">
      <div className="flex items-center gap-3 px-5 pb-5 pt-4">
        <Button aria-label="Go back" onClick={onBack} className="flex size-10 shrink-0 items-center justify-center rounded-full bg-white text-ink shadow-soft">
          <ArrowLeft size={19} />
        </Button>
        <div className="min-w-0 flex-1">
          <div className="truncate text-lg font-extrabold tracking-[-0.03em] text-ink">{workspace.name}</div>
          <div className="mt-0.5 text-[10px] font-semibold text-muted">{workspace.currentUserRole} · {workspace.members.length} members</div>
        </div>
        <Button onClick={onInvite} className="flex items-center gap-1.5 rounded-full bg-ink px-3 py-2 text-[10px] font-bold text-white">
          <Plus size={13} /> Invite
        </Button>
      </div>

      <div className="px-5">
        <div className="relative overflow-hidden rounded-[28px] bg-ink p-5 text-white shadow-card">
          <div className="absolute -right-8 -top-10 size-32 rounded-full border border-white/10" />
          <div className="relative">
            <div className="flex items-center justify-between">
              <span className="rounded-full bg-white/10 px-2.5 py-1 text-[9px] font-bold uppercase tracking-wider text-white/70">
                {workspace.currentUserRole}
              </span>
              <LayoutGrid size={19} className="text-white/35" />
            </div>
            <div className="mt-5 text-[21px] font-extrabold tracking-[-0.035em]">{workspace.name}</div>
            <div className="mt-2 max-w-[270px] text-[11px] leading-5 text-white/55">{workspace.description}</div>
            <Button onClick={onInvite} className="mt-5 flex items-center gap-2 rounded-full bg-white px-3.5 py-2.5 text-[10px] font-bold text-ink">
              <Copy size={13} /> Invite code: {workspace.code}
            </Button>
          </div>
        </div>

        <div className="mt-4 grid grid-cols-3 divide-x divide-line rounded-[22px] bg-white py-4 shadow-soft">
          <Button onClick={() => navigate({ kind: "stats", title: "Workspace memos", subtitle: `${workspace.memos} in ${workspace.name}` })}>
            <Stat value={`${workspace.memos}`} label="Memos" />
          </Button>
          <Button onClick={() => navigate({ kind: "stats", title: "Active tasks", subtitle: `${workspace.activeTasks} in progress` })}>
            <Stat value={`${workspace.activeTasks}`} label="Active" />
          </Button>
          <Button onClick={() => navigate({ kind: "stats", title: "Completed tasks", subtitle: `${workspace.completedTasks} completed` })}>
            <Stat value={`${workspace.completedTasks}`} label="Done" />
          </Button>
        </div>

        <div className="mt-5 flex rounded-2xl bg-soft p-1">
          {(["Overview", "Hybrid Board"] as const).map((item) => (
            <Button
              key={item}
              onClick={() => setSection(item)}
              className={`flex-1 rounded-xl py-2 text-[10px] font-bold transition ${section === item ? "bg-white text-ink shadow-soft" : "text-muted"}`}
            >
              {item}
            </Button>
          ))}
        </div>

        {section === "Overview" && (
          <div className="mt-6">
            <SectionTitle
              title="Members"
              action="View all"
              onAction={() => navigate({ kind: "members", title: "Workspace members", subtitle: workspace.name, workspaceId: workspace.id })}
            />
            <div className="overflow-hidden rounded-[24px] bg-white px-4 shadow-soft">
              {workspace.members.slice(0, 4).map((member, index) => (
                <Button
                  key={member.id}
                  onClick={() => navigate({ kind: "profile", title: member.name, subtitle: member.role })}
                  className={`flex w-full items-center gap-3 py-3.5 text-left ${index < Math.min(workspace.members.length, 4) - 1 ? "border-b border-line" : ""}`}
                >
                  <Avatar initials={member.initials} tone={member.tone} className="size-9" />
                  <div className="min-w-0 flex-1">
                    <div className="truncate text-xs font-bold text-ink">{member.name}</div>
                    <div className="mt-0.5 text-[9px] text-faint">{member.status}</div>
                  </div>
                  <span className={`rounded-full px-2 py-1 text-[8px] font-bold ${member.role === "Owner" ? "bg-peach text-caramel" : "bg-surface text-muted"}`}>
                    {member.role}
                  </span>
                </Button>
              ))}
            </div>

            <div className="mt-6">
              <SectionTitle title="Recent activity" action="View all" onAction={() => navigate({ kind: "activity", title: "Workspace activity", subtitle: workspace.name })} />
              <div className="space-y-4 rounded-[24px] bg-white p-4 shadow-soft">
                <Activity avatar="AR" tone="sand" name="Ardi" text="updated" subject="Launch checklist" time="18m" onClick={() => navigate({ kind: "memo", title: "Launch checklist", subtitle: workspace.name })} />
                <Activity avatar="JD" tone="olive" name="Jade" text="completed" subject="Mobile design QA" time="2h" onClick={() => navigate({ kind: "task", title: "Mobile design QA", subtitle: workspace.name })} />
              </div>
            </div>
          </div>
        )}
        {section === "Hybrid Board" && (
          <div className="mt-6">
            <div className="mb-3 flex items-center justify-between">
              <div>
                <div className="text-[17px] font-bold tracking-[-0.02em] text-ink">Hybrid Board</div>
                <div className="mt-1 text-[9px] text-faint">Drag cards to organize your team’s work.</div>
              </div>
              <div className="flex rounded-full bg-soft p-1">
                {(["Kanban", "Canvas"] as const).map((item) => (
                  <Button
                    key={item}
                    onClick={() => setBoardView(item)}
                    className={`rounded-full px-3 py-2 text-[9px] font-bold transition ${boardView === item ? "bg-white text-ink shadow-soft" : "text-muted"}`}
                  >
                    {item}
                  </Button>
                ))}
              </div>
            </div>
            <div className={boardView === "Kanban" ? "block" : "hidden"}>
              <BoardView navigate={navigate} openSheet={openSheet} workspaceName={workspace.name} />
            </div>
            <div className={boardView === "Canvas" ? "block" : "hidden"}>
              <CanvasView navigate={navigate} openSheet={openSheet} />
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

function BoardView({ navigate, openSheet, workspaceName }: { navigate: Navigate; openSheet: OpenSheet; workspaceName: string }) {
  type KanbanCard = { id: string; title: string; details: string; label: string; assignee: string; tone: MemberTone; dueDate: string; comments: number };
  type KanbanColumn = { id: string; title: string; dot: string; cards: KanbanCard[] };
  const [columns, setColumns] = useState<KanbanColumn[]>([
    {
      id: "planned",
      title: "Rencana",
      dot: "bg-caramel",
      cards: [
        { id: "pricing", title: "Explore pricing tiers", details: "Compare packaging options for the launch.", label: "Strategy", assignee: "NA", tone: "dark", dueDate: dateOffset(3), comments: 4 },
        { id: "email", title: "Draft launch email", details: "Write the first announcement draft.", label: "Marketing", assignee: "AR", tone: "sand", dueDate: dateOffset(0), comments: 2 },
        { id: "interviews", title: "Plan customer interviews", details: "Recruit five active workspace users.", label: "Research", assignee: "JD", tone: "olive", dueDate: dateOffset(6), comments: 6 },
      ],
    },
    {
      id: "doing",
      title: "Dikerjakan",
      dot: "bg-plum",
      cards: [
        { id: "onboarding", title: "Polish onboarding flow", details: "Resolve the final usability issues.", label: "Product", assignee: "NA", tone: "dark", dueDate: dateOffset(-1), comments: 8 },
        { id: "mobile-qa", title: "Mobile design QA", details: "Check all screens at the target viewport.", label: "Design", assignee: "JD", tone: "olive", dueDate: dateOffset(2), comments: 3 },
      ],
    },
    {
      id: "done",
      title: "Selesai",
      dot: "bg-olive",
      cards: [
        { id: "analytics", title: "Set up product analytics", details: "Track activation and board engagement.", label: "Data", assignee: "AR", tone: "sand", dueDate: dateOffset(-3), comments: 5 },
        { id: "notes", title: "Review interview notes", details: "Summarize the strongest recurring themes.", label: "Research", assignee: "NA", tone: "dark", dueDate: dateOffset(-4), comments: 1 },
      ],
    },
  ]);
  const [dragged, setDragged] = useState<{ cardId: string; sourceId: string } | null>(null);
  const [dropTarget, setDropTarget] = useState<string | null>(null);
  const didDrag = useRef(false);
  const [taskForm, setTaskForm] = useState<{ columnId: string; cardId?: string } | null>(null);
  const [taskTitle, setTaskTitle] = useState("");
  const [taskDetails, setTaskDetails] = useState("");
  const [taskAssignee, setTaskAssignee] = useState<{ initials: string; tone: MemberTone }>({ initials: "NA", tone: "dark" });
  const [taskDueDate, setTaskDueDate] = useState("");
  const assignees: { initials: string; name: string; tone: MemberTone }[] = [
    { initials: "NA", name: "Naya", tone: "dark" },
    { initials: "AR", name: "Ardi", tone: "sand" },
    { initials: "JD", name: "Jade", tone: "olive" },
  ];

  const openTaskForm = (columnId: string, card?: KanbanCard) => {
    setTaskForm({ columnId, cardId: card?.id });
    setTaskTitle(card?.title || "");
    setTaskDetails(card?.details || "");
    setTaskAssignee(card ? { initials: card.assignee, tone: card.tone } : { initials: "NA", tone: "dark" });
    setTaskDueDate(card?.dueDate || "");
  };
  const saveTask = () => {
    if (!taskForm || !taskTitle.trim() || !taskDueDate) return;
    setColumns((current) =>
      current.map((column) => {
        if (taskForm.cardId) {
          return {
            ...column,
            cards: column.cards.map((card) =>
              card.id === taskForm.cardId
                ? { ...card, title: taskTitle.trim(), details: taskDetails.trim(), assignee: taskAssignee.initials, tone: taskAssignee.tone, dueDate: taskDueDate }
                : card,
            ),
          };
        }
        return column.id === taskForm.columnId
          ? {
              ...column,
              cards: [
                ...column.cards,
                {
                  id: `task-${Date.now()}`,
                  title: taskTitle.trim(),
                  details: taskDetails.trim() || "New workspace task.",
                  label: "Task",
                  assignee: taskAssignee.initials,
                  tone: taskAssignee.tone,
                  dueDate: taskDueDate,
                  comments: 0,
                },
              ],
            }
          : column;
      }),
    );
    setTaskForm(null);
  };
  const removeTaskDueDate = () => {
    if (!taskForm?.cardId) return;
    setColumns((current) => current.map((column) => ({ ...column, cards: column.cards.map((card) => card.id === taskForm.cardId ? { ...card, dueDate: "" } : card) })));
    setTaskForm(null);
  };

  const moveCard = (targetId: string) => {
    if (!dragged || dragged.sourceId === targetId) {
      setDragged(null);
      setDropTarget(null);
      return;
    }
    let movingCard: KanbanCard | undefined;
    columns.forEach((column) => {
      const match = column.cards.find((card) => card.id === dragged.cardId);
      if (match) movingCard = match;
    });
    if (!movingCard) return;
    setColumns((current) =>
      current.map((column) => {
        const withoutMoving = column.cards.filter((card) => card.id !== dragged.cardId);
        return column.id === targetId ? { ...column, cards: [...withoutMoving, movingCard!] } : { ...column, cards: withoutMoving };
      }),
    );
    setDragged(null);
    setDropTarget(null);
  };

  return (
    <div className="flex snap-x gap-3 overflow-x-auto pb-4 scrollbar-none">
      {columns.map((column) => (
        <div
          key={column.id}
          onDragOver={(event) => {
            event.preventDefault();
            setDropTarget(column.id);
          }}
          onDragLeave={(event) => {
            if (!event.currentTarget.contains(event.relatedTarget as Node)) setDropTarget(null);
          }}
          onDrop={(event) => {
            event.preventDefault();
            moveCard(column.id);
          }}
          className={`w-[270px] shrink-0 snap-start rounded-[24px] p-3 transition ${dropTarget === column.id ? "bg-mint ring-2 ring-olive/20" : "bg-white/55"}`}
        >
          <div className="flex items-center gap-2 px-1 py-1">
            <span className={`size-2 rounded-full ${column.dot}`} />
            <span className="text-xs font-bold text-ink">{column.title}</span>
            <span className="ml-auto rounded-full bg-white px-2 py-0.5 text-[10px] font-bold text-muted">{column.cards.length}</span>
          </div>
          <div className="mt-2 space-y-2">
            {column.cards.map((card) => (
              <div
                key={card.id}
                draggable
                onDragStart={(event) => {
                  didDrag.current = true;
                  event.dataTransfer.effectAllowed = "move";
                  event.dataTransfer.setData("text/plain", card.id);
                  setDragged({ cardId: card.id, sourceId: column.id });
                }}
                onDragEnd={() => {
                  setDragged(null);
                  setDropTarget(null);
                  window.setTimeout(() => { didDrag.current = false; }, 0);
                }}
                className={`w-full rounded-[20px] bg-white p-4 text-left shadow-soft transition ${dragged?.cardId === card.id ? "opacity-40" : "hover:-translate-y-0.5"}`}
              >
                <div className="flex items-start gap-2">
                  <Button
                    onClick={() => {
                      if (!didDrag.current) navigate({ kind: "task", title: card.title, subtitle: `${column.title} · ${workspaceName}` });
                    }}
                    className="min-w-0 flex-1 text-left"
                  >
                    <span className="rounded-full bg-surface px-2 py-1 text-[8px] font-bold uppercase tracking-wider text-muted">{card.label}</span>
                    <div className="mt-3 text-xs font-bold leading-5 text-ink">{card.title}</div>
                    <div className="mt-1 line-clamp-2 text-[9px] leading-4 text-faint">{card.details}</div>
                  </Button>
                  <GripVertical size={15} className="shrink-0 text-line" />
                </div>
                <div className="mt-4 flex items-center">
                  <Avatar initials={card.assignee} tone={card.tone} className="size-6" />
                  <div className="ml-2 flex items-center gap-1 text-[9px] text-faint"><MessageCircle size={11} /> {card.comments}</div>
                  <div className="ml-auto">
                    {card.dueDate ? (
                      <DeadlineBadge date={card.dueDate} completed={column.id === "done"} onClick={() => openTaskForm(column.id, card)} />
                    ) : (
                      <Button onClick={() => openTaskForm(column.id, card)} className="text-[8px] font-bold text-faint">Add date</Button>
                    )}
                  </div>
                </div>
              </div>
            ))}
            <Button onClick={() => openTaskForm(column.id)} className="flex w-full items-center justify-center gap-1 rounded-2xl border border-dashed border-line py-3 text-[11px] font-bold text-muted">
              <Plus size={14} /> Add card
            </Button>
          </div>
        </div>
      ))}
      {taskForm && (
        <SheetFrame
          title={taskForm.cardId ? "Edit task" : "Add task"}
          description="Add details, assign a teammate, and set a due date."
          onClose={() => setTaskForm(null)}
        >
          <div className="mt-5 space-y-3">
            <label className="block rounded-[20px] bg-white px-4 py-3 shadow-soft">
              <span className="text-[9px] font-bold uppercase tracking-wider text-faint">Task details</span>
              <Input value={taskTitle} onChange={(event) => setTaskTitle(event.target.value)} placeholder="Task title" className="mt-1.5 text-xs font-bold text-ink placeholder:text-faint" />
              <Input value={taskDetails} onChange={(event) => setTaskDetails(event.target.value)} placeholder="Add a short description" className="mt-2 text-[10px] text-muted placeholder:text-faint" />
            </label>
            <div className="rounded-[20px] bg-white p-4 shadow-soft">
              <div className="text-[9px] font-bold uppercase tracking-wider text-faint">Assign teammate</div>
              <div className="mt-3 flex gap-2">
                {assignees.map((assignee) => (
                  <Button
                    key={assignee.initials}
                    onClick={() => setTaskAssignee({ initials: assignee.initials, tone: assignee.tone })}
                    className={`flex items-center gap-2 rounded-full px-2.5 py-1.5 text-[9px] font-bold ${taskAssignee.initials === assignee.initials ? "bg-ink text-white" : "bg-surface text-muted"}`}
                  >
                    <Avatar initials={assignee.initials} tone={assignee.tone} className="size-6" /> {assignee.name}
                  </Button>
                ))}
              </div>
            </div>
            <label className="block rounded-[20px] bg-white px-4 py-3 shadow-soft">
              <span className="text-[9px] font-bold uppercase tracking-wider text-faint">Due date</span>
              <Input type="date" value={taskDueDate} onChange={(event) => setTaskDueDate(event.target.value)} className="mt-1.5 text-xs font-semibold text-ink" />
            </label>
          </div>
          <div className="mt-4 flex gap-2">
            {taskForm.cardId && <Button onClick={removeTaskDueDate} className="rounded-full bg-white px-4 py-3 text-[10px] font-bold text-danger shadow-soft">Remove date</Button>}
            <Button onClick={() => setTaskForm(null)} className="ml-auto rounded-full bg-white px-4 py-3 text-[10px] font-bold text-muted shadow-soft">Cancel</Button>
            <Button disabled={!taskTitle.trim() || !taskDueDate} onClick={saveTask} className="rounded-full bg-ink px-4 py-3 text-[10px] font-bold text-white disabled:opacity-30">Save task</Button>
          </div>
        </SheetFrame>
      )}
    </div>
  );
}

function CanvasView({ navigate, openSheet }: { navigate: Navigate; openSheet: OpenSheet }) {
  type CanvasMemo = {
    id: string;
    title: string;
    body: string;
    x: number;
    y: number;
    color: string;
    accent: string;
    icon: LucideIcon;
    initials: string;
  };
  const [cards, setCards] = useState<CanvasMemo[]>([
    { id: "big-idea", title: "Big idea", body: "Make collaboration feel calm, not crowded.", x: 90, y: 70, color: "bg-peach", accent: "text-caramel", icon: Sparkles, initials: "NA" },
    { id: "next-steps", title: "Next steps", body: "Interview users and prototype the sharing flow.", x: 360, y: 105, color: "bg-mint", accent: "text-olive", icon: CheckCircle2, initials: "JD" },
    { id: "research", title: "Research signal", body: "Teams want one place for decisions and context.", x: 185, y: 290, color: "bg-lilac", accent: "text-plum", icon: BookOpen, initials: "AR" },
    { id: "launch", title: "Launch thought", body: "Lead with focus, then reveal the flexible workspace.", x: 510, y: 330, color: "bg-white", accent: "text-muted", icon: Zap, initials: "NA" },
  ]);
  const [viewport, setViewport] = useState({ x: -35, y: -15, scale: 0.78 });
  const [panning, setPanning] = useState(false);
  const interaction = useRef<{
    mode: "pan" | "card";
    startX: number;
    startY: number;
    originX: number;
    originY: number;
    cardId?: string;
  } | null>(null);
  const moved = useRef(false);
  const [canvasAction, setCanvasAction] = useState<"menu" | "sticky" | "checklist" | null>(null);
  const [canvasTitle, setCanvasTitle] = useState("");
  const [canvasBody, setCanvasBody] = useState("");
  const clampScale = (scale: number) => Math.min(1.6, Math.max(0.5, scale));
  const zoomBy = (amount: number) => setViewport((current) => ({ ...current, scale: clampScale(current.scale + amount) }));
  const fitToScreen = () => {
    if (!cards.length) return;
    const minX = Math.min(...cards.map((card) => card.x));
    const minY = Math.min(...cards.map((card) => card.y));
    const maxX = Math.max(...cards.map((card) => card.x + 192));
    const maxY = Math.max(...cards.map((card) => card.y + 180));
    const contentWidth = maxX - minX;
    const contentHeight = maxY - minY;
    const scale = clampScale(Math.min(330 / contentWidth, 420 / contentHeight, 1));
    setViewport({
      x: (350 - contentWidth * scale) / 2 - minX * scale,
      y: (470 - contentHeight * scale) / 2 - minY * scale,
      scale,
    });
    setCanvasAction(null);
  };
  const saveCanvasCard = () => {
    if (!canvasAction || canvasAction === "menu" || !canvasTitle.trim()) return;
    const isChecklist = canvasAction === "checklist";
    setCards((current) => [
      ...current,
      {
        id: `canvas-${Date.now()}`,
        title: canvasTitle.trim(),
        body: canvasBody.trim() || (isChecklist ? "New checklist item" : "New sticky note"),
        x: 220 + current.length * 28,
        y: 180 + current.length * 22,
        color: isChecklist ? "bg-mint" : "bg-peach",
        accent: isChecklist ? "text-olive" : "text-caramel",
        icon: isChecklist ? CheckCircle2 : FileText,
        initials: "NA",
      },
    ]);
    setCanvasTitle("");
    setCanvasBody("");
    setCanvasAction(null);
  };

  const startPan = (event: React.PointerEvent<HTMLDivElement>) => {
    event.currentTarget.setPointerCapture(event.pointerId);
    interaction.current = { mode: "pan", startX: event.clientX, startY: event.clientY, originX: viewport.x, originY: viewport.y };
    setPanning(true);
  };
  const startCardDrag = (event: React.PointerEvent<HTMLButtonElement>, card: CanvasMemo) => {
    event.stopPropagation();
    event.currentTarget.setPointerCapture(event.pointerId);
    interaction.current = { mode: "card", cardId: card.id, startX: event.clientX, startY: event.clientY, originX: card.x, originY: card.y };
    moved.current = false;
  };
  const movePointer = (event: React.PointerEvent<HTMLDivElement>) => {
    const active = interaction.current;
    if (!active) return;
    const dx = event.clientX - active.startX;
    const dy = event.clientY - active.startY;
    if (Math.abs(dx) + Math.abs(dy) > 4) moved.current = true;
    if (active.mode === "pan") {
      setViewport((current) => ({ ...current, x: active.originX + dx, y: active.originY + dy }));
    } else {
      setCards((current) =>
        current.map((card) =>
          card.id === active.cardId
            ? { ...card, x: active.originX + dx / viewport.scale, y: active.originY + dy / viewport.scale }
            : card,
        ),
      );
    }
  };
  const endPointer = () => {
    interaction.current = null;
    setPanning(false);
    window.setTimeout(() => { moved.current = false; }, 0);
  };

  return (
    <>
      <div
      onPointerDown={startPan}
      onPointerMove={movePointer}
      onPointerUp={endPointer}
      onPointerCancel={endPointer}
      onWheel={(event) => {
        event.preventDefault();
        zoomBy(event.deltaY > 0 ? -0.08 : 0.08);
      }}
      className={`relative h-[500px] touch-none overflow-hidden rounded-[28px] bg-white shadow-soft canvas-grid ${panning ? "cursor-grabbing" : "cursor-grab"}`}
    >
      <div className="pointer-events-none absolute left-4 top-4 z-20 flex items-center gap-1.5 rounded-full bg-white/90 px-3 py-2 text-[9px] font-semibold text-muted shadow-soft backdrop-blur">
        <Hand size={12} /> Drag empty space to pan
      </div>
      <div
        className="absolute left-0 top-0 h-[800px] w-[900px]"
        style={{ transform: `translate(${viewport.x}px, ${viewport.y}px) scale(${viewport.scale})`, transformOrigin: "0 0" }}
      >
        {cards.map((card) => {
          const Icon = card.icon;
          return (
            <Button
              key={card.id}
              onPointerDown={(event) => startCardDrag(event, card)}
              onClick={() => {
                if (!moved.current) navigate({ kind: "canvas-note", title: card.title, subtitle: "Canvas memo" });
              }}
              className={`absolute w-48 cursor-grab rounded-[22px] p-4 text-left shadow-card active:cursor-grabbing ${card.color}`}
              style={{ left: card.x, top: card.y }}
            >
              <div className="flex items-start justify-between">
                <div className={`flex size-8 items-center justify-center rounded-xl bg-white/60 ${card.accent}`}><Icon size={15} /></div>
                <GripVertical size={15} className="text-ink/20" />
              </div>
              <div className="mt-4 text-xs font-extrabold text-ink">{card.title}</div>
              <div className="mt-2 text-[10px] leading-5 text-muted">{card.body}</div>
              <div className="mt-4 flex items-center border-t border-ink/5 pt-3">
                <Avatar initials={card.initials} className="size-6" />
                <span className="ml-2 text-[8px] font-semibold text-faint">Updated today</span>
              </div>
            </Button>
          );
        })}
      </div>
      <div
        className="absolute bottom-4 right-4 z-20 flex items-center gap-1 rounded-full bg-ink p-1.5 text-white shadow-card"
        onPointerDown={(event) => event.stopPropagation()}
      >
        <Button onClick={() => zoomBy(-0.1)} aria-label="Zoom out" className="flex size-8 items-center justify-center rounded-full text-white hover:bg-white/10"><Minus size={14} /></Button>
        <Button onClick={() => setViewport({ x: -35, y: -15, scale: 1 })} className="min-w-10 rounded-full py-2 text-[9px] font-bold text-white">
          {Math.round(viewport.scale * 100)}%
        </Button>
        <Button onClick={() => zoomBy(0.1)} aria-label="Zoom in" className="flex size-8 items-center justify-center rounded-full text-white hover:bg-white/10"><Plus size={14} /></Button>
      </div>
      <Button
        onPointerDown={(event) => event.stopPropagation()}
        onClick={() => setCanvasAction("menu")}
        className="absolute bottom-4 left-4 z-20 flex items-center gap-1.5 rounded-full bg-white px-3 py-2.5 text-[9px] font-bold text-ink shadow-card"
      >
        <Plus size={13} /> Add memo
      </Button>
      </div>

      {canvasAction === "menu" && (
        <SheetFrame title="Add to canvas" description="Create a new item or fit all cards into view." onClose={() => setCanvasAction(null)}>
          <div className="mt-5 space-y-2.5">
            <Button onClick={() => { setCanvasTitle(""); setCanvasBody(""); setCanvasAction("sticky"); }} className="flex w-full items-center gap-3 rounded-[20px] bg-white p-4 text-left shadow-soft">
              <span className="flex size-10 items-center justify-center rounded-xl bg-peach text-caramel"><FileText size={17} /></span>
              <span className="flex-1"><span className="block text-xs font-bold text-ink">Add Sticky Note</span><span className="mt-1 block text-[9px] text-faint">Capture a thought anywhere on the canvas.</span></span>
              <ChevronRight size={15} className="text-faint" />
            </Button>
            <Button onClick={() => { setCanvasTitle(""); setCanvasBody(""); setCanvasAction("checklist"); }} className="flex w-full items-center gap-3 rounded-[20px] bg-white p-4 text-left shadow-soft">
              <span className="flex size-10 items-center justify-center rounded-xl bg-mint text-olive"><CheckCircle2 size={17} /></span>
              <span className="flex-1"><span className="block text-xs font-bold text-ink">Add Checklist</span><span className="mt-1 block text-[9px] text-faint">Add an actionable item to the canvas.</span></span>
              <ChevronRight size={15} className="text-faint" />
            </Button>
            <Button onClick={fitToScreen} className="flex w-full items-center gap-3 rounded-[20px] bg-white p-4 text-left shadow-soft">
              <span className="flex size-10 items-center justify-center rounded-xl bg-surface text-muted"><LayoutGrid size={17} /></span>
              <span className="flex-1"><span className="block text-xs font-bold text-ink">Fit to Screen</span><span className="mt-1 block text-[9px] text-faint">Center every card at the best zoom level.</span></span>
              <ChevronRight size={15} className="text-faint" />
            </Button>
          </div>
        </SheetFrame>
      )}

      {(canvasAction === "sticky" || canvasAction === "checklist") && (
        <SheetFrame
          title={canvasAction === "sticky" ? "Add sticky note" : "Add checklist"}
          description="This item will appear immediately on the canvas."
          onClose={() => setCanvasAction(null)}
        >
          <div className="mt-5 space-y-3">
            <label className="block rounded-[20px] bg-white px-4 py-3 shadow-soft">
              <span className="text-[9px] font-bold uppercase tracking-wider text-faint">Title</span>
              <Input value={canvasTitle} onChange={(event) => setCanvasTitle(event.target.value)} placeholder={canvasAction === "sticky" ? "Note title" : "Checklist title"} className="mt-1.5 text-xs font-bold text-ink placeholder:text-faint" />
            </label>
            <label className="block rounded-[20px] bg-white px-4 py-3 shadow-soft">
              <span className="text-[9px] font-bold uppercase tracking-wider text-faint">{canvasAction === "sticky" ? "Note" : "First item"}</span>
              <Input value={canvasBody} onChange={(event) => setCanvasBody(event.target.value)} placeholder="Add details" className="mt-1.5 text-xs text-muted placeholder:text-faint" />
            </label>
          </div>
          <div className="mt-4 flex gap-2">
            <Button onClick={() => setCanvasAction(null)} className="ml-auto rounded-full bg-white px-4 py-3 text-[10px] font-bold text-muted shadow-soft">Cancel</Button>
            <Button disabled={!canvasTitle.trim()} onClick={saveCanvasCard} className="rounded-full bg-ink px-4 py-3 text-[10px] font-bold text-white disabled:opacity-30">Add to canvas</Button>
          </div>
        </SheetFrame>
      )}
    </>
  );
}

function ProfilePage({
  onNotify,
  navigate,
  openSheet,
}: {
  onNotify: () => void;
  navigate: Navigate;
  openSheet: OpenSheet;
}) {
  return (
    <>
      <Header
        title="Your profile"
        subtitle="Account & settings"
        onNotify={onNotify}
        onSearch={() => navigate({ kind: "search", title: "Search MemoSpace", subtitle: "Settings, help & content" })}
      />
      <div className="px-5 pb-32">
        <div className="flex flex-col items-center rounded-[28px] bg-ink px-5 py-7 text-white shadow-card">
          <Avatar initials="NA" className="size-20 text-xl ring-4 ring-white/10" />
          <div className="mt-4 text-lg font-bold">Naya Anindita</div>
          <div className="mt-1 text-xs text-white/50">naya@memospace.app</div>
          <Button onClick={() => openSheet("edit-profile")} className="mt-5 rounded-full bg-white/10 px-4 py-2 text-xs font-bold text-white">Edit profile</Button>
        </div>
        <div className="mt-5 grid grid-cols-3 divide-x divide-line rounded-[22px] bg-white py-4 shadow-soft">
          <Button onClick={() => navigate({ kind: "stats", title: "Your memos", subtitle: "48 total" })}><Stat value="48" label="Memos" /></Button>
          <Button onClick={() => navigate({ kind: "stats", title: "Your workspaces", subtitle: "3 active" })}><Stat value="3" label="Spaces" /></Button>
          <Button onClick={() => navigate({ kind: "stats", title: "Shared with you", subtitle: "12 items" })}><Stat value="12" label="Shared" /></Button>
        </div>
        <div className="mt-7">
          <SectionTitle title="Preferences" />
          <div className="overflow-hidden rounded-[24px] bg-white px-4 shadow-soft">
            <ProfileRow icon={Settings} label="Account settings" onClick={() => navigate({ kind: "settings", title: "Account settings", subtitle: "Profile, email & security" })} />
            <ProfileRow icon={Bell} label="Notifications" value="On" onClick={() => openSheet("notification-settings")} />
            <ProfileRow icon={BookOpen} label="Language" value="English" onClick={() => openSheet("language")} />
            <ProfileRow icon={MessageCircle} label="Help & feedback" last onClick={() => navigate({ kind: "help", title: "Help & feedback", subtitle: "How can we help?" })} />
          </div>
        </div>
        <Button onClick={() => navigate({ kind: "upgrade", title: "MemoSpace Plus", subtitle: "More room for your ideas" })} className="mt-5 w-full rounded-[22px] bg-mint p-4 text-left">
          <div className="flex items-center gap-3">
            <div className="flex size-10 items-center justify-center rounded-2xl bg-white text-olive"><Sparkles size={18} /></div>
            <div className="flex-1">
              <div className="text-xs font-bold text-ink">MemoSpace Plus</div>
              <div className="mt-1 text-[10px] text-muted">Unlock unlimited shared spaces</div>
            </div>
            <ChevronRight size={17} className="text-muted" />
          </div>
        </Button>
      </div>
    </>
  );
}

function ProfileRow({ icon: Icon, label, value, last, onClick }: { icon: LucideIcon; label: string; value?: string; last?: boolean; onClick: () => void }) {
  return (
    <Button onClick={onClick} className={`flex w-full items-center gap-3 py-4 text-left ${last ? "" : "border-b border-line"}`}>
      <Icon size={17} className="text-muted" />
      <span className="flex-1 text-xs font-semibold text-ink">{label}</span>
      {value && <span className="text-[10px] text-faint">{value}</span>}
      <ChevronRight size={15} className="text-faint" />
    </Button>
  );
}

function DetailHeader({ screen, onBack, openSheet }: { screen: Screen; onBack: () => void; openSheet: OpenSheet }) {
  return (
    <div className="flex items-center gap-3 px-5 pb-5 pt-4">
      <Button
        aria-label="Go back"
        onClick={onBack}
        className="flex size-10 shrink-0 items-center justify-center rounded-full bg-white text-ink shadow-soft"
      >
        <ArrowLeft size={19} />
      </Button>
      <div className="min-w-0 flex-1">
        <div className="truncate text-lg font-extrabold tracking-[-0.03em] text-ink">{screen.title}</div>
        {screen.subtitle && <div className="mt-0.5 truncate text-[10px] font-semibold text-muted">{screen.subtitle}</div>}
      </div>
      <Button
        aria-label="Screen actions"
        onClick={() => openSheet(screen.kind === "asset" ? "asset-actions" : "memo-actions")}
        className="flex size-10 shrink-0 items-center justify-center rounded-full bg-white text-ink shadow-soft"
      >
        <MoreHorizontal size={19} />
      </Button>
    </div>
  );
}

function MemoEditor({ screen, navigate }: { screen: Screen; navigate: Navigate }) {
  type Attachment = { id: string; type: "Photo" | "Video" | "PDF" | "Document"; name: string; meta: string; icon: LucideIcon; color: string };
  type CommentReply = { id: string; name: string; initials: string; tone: MemberTone; body: string; time: string };
  type Comment = CommentReply & { replies: CommentReply[] };
  const isNewMemo = screen.title === "Untitled memo" || screen.title === "New checklist";
  const editorRef = useRef<HTMLDivElement>(null);
  const [title, setTitle] = useState(screen.title === "Untitled memo" ? "" : screen.title);
  const [dirty, setDirty] = useState(false);
  const [savedAt, setSavedAt] = useState("Saved 18 min ago");
  const [attachmentPicker, setAttachmentPicker] = useState(false);
  const [attachments, setAttachments] = useState<Attachment[]>(isNewMemo ? [] : [
    { id: "photo-1", type: "Photo", name: "Workshop whiteboard.jpg", meta: "2.4 MB", icon: Image, color: "bg-peach text-caramel" },
    { id: "video-1", type: "Video", name: "Prototype walkthrough.mp4", meta: "01:42 · 18 MB", icon: Video, color: "bg-lilac text-plum" },
    { id: "pdf-1", type: "PDF", name: "Research summary.pdf", meta: "8 pages · 3.1 MB", icon: FileText, color: "bg-mint text-olive" },
    { id: "doc-1", type: "Document", name: "Interview notes.docx", meta: "420 KB", icon: File, color: "bg-surface text-muted" },
  ]);
  const [checklist, setChecklist] = useState(
    screen.title === "New checklist"
      ? [{ id: "check-new", text: "First checklist item", done: false }]
      : isNewMemo
        ? []
        : [
            { id: "check-1", text: "Refine the core problem statement", done: true },
            { id: "check-2", text: "Add supporting research links", done: false },
            { id: "check-3", text: "Share the draft with the product team", done: false },
          ],
  );
  const [newChecklist, setNewChecklist] = useState("");
  const [editingChecklist, setEditingChecklist] = useState<string | null>(null);
  const [editingChecklistText, setEditingChecklistText] = useState("");
  const [dueDate, setDueDate] = useState(isNewMemo ? "" : dateOffset(2));
  const [comments, setComments] = useState<Comment[]>([
    {
      id: "comment-1",
      name: "Ardi Rahman",
      initials: "AR",
      tone: "sand",
      body: "The framing is much clearer now. I’d keep the customer quote near the top.",
      time: "12m",
      replies: [
        { id: "reply-1", name: "Naya Anindita", initials: "NA", tone: "dark", body: "Good call — I moved it into the opening section.", time: "8m" },
      ],
    },
    {
      id: "comment-2",
      name: "Jade Diaz",
      initials: "JD",
      tone: "olive",
      body: "Can we link the latest prototype before tomorrow’s review?",
      time: "1h",
      replies: [],
    },
  ]);
  const [commentText, setCommentText] = useState("");
  const [replyingTo, setReplyingTo] = useState<string | null>(null);
  const [replyText, setReplyText] = useState("");
  const initialContent = useRef(
    isNewMemo
      ? "<p><br></p>"
      : "<p>Our goal is to make shared work feel focused and calm. This memo captures the decisions, research signals, and next steps for the upcoming release.</p><p><strong>What we learned</strong></p><p>People want the flexibility of a canvas without losing the clarity of a structured workflow. The experience should move naturally between both modes.</p>",
  );

  const formatText = (command: string, value?: string) => {
    editorRef.current?.focus();
    document.execCommand(command, false, value);
    setDirty(true);
  };
  const saveMemo = () => {
    setDirty(false);
    setSavedAt("Saved just now");
  };
  const addAttachment = (type: Attachment["type"]) => {
    const options: Record<Attachment["type"], Attachment> = {
      Photo: { id: `photo-${Date.now()}`, type: "Photo", name: "Design reference.jpg", meta: "1.8 MB", icon: Image, color: "bg-peach text-caramel" },
      Video: { id: `video-${Date.now()}`, type: "Video", name: "New recording.mp4", meta: "00:48 · 9 MB", icon: Video, color: "bg-lilac text-plum" },
      PDF: { id: `pdf-${Date.now()}`, type: "PDF", name: "Project brief.pdf", meta: "4 pages · 1.2 MB", icon: FileText, color: "bg-mint text-olive" },
      Document: { id: `doc-${Date.now()}`, type: "Document", name: "Project notes.docx", meta: "680 KB", icon: File, color: "bg-surface text-muted" },
    };
    setAttachments((current) => [...current, options[type]]);
    setDirty(true);
    setAttachmentPicker(false);
  };
  const addChecklistItem = () => {
    if (!newChecklist.trim()) return;
    setChecklist((current) => [...current, { id: `check-${Date.now()}`, text: newChecklist.trim(), done: false }]);
    setNewChecklist("");
    setDirty(true);
  };
  const saveChecklistEdit = (itemId: string) => {
    if (!editingChecklistText.trim()) return;
    setChecklist((current) => current.map((item) => item.id === itemId ? { ...item, text: editingChecklistText.trim() } : item));
    setEditingChecklist(null);
    setEditingChecklistText("");
    setDirty(true);
  };
  const addComment = () => {
    if (!commentText.trim()) return;
    setComments((current) => [
      ...current,
      { id: `comment-${Date.now()}`, name: "Naya Anindita", initials: "NA", tone: "dark", body: commentText.trim(), time: "now", replies: [] },
    ]);
    setCommentText("");
  };
  const addReply = (commentId: string) => {
    if (!replyText.trim()) return;
    setComments((current) =>
      current.map((comment) =>
        comment.id === commentId
          ? {
              ...comment,
              replies: [
                ...comment.replies,
                { id: `reply-${Date.now()}`, name: "Naya Anindita", initials: "NA", tone: "dark", body: replyText.trim(), time: "now" },
              ],
            }
          : comment,
      ),
    );
    setReplyText("");
    setReplyingTo(null);
  };

  return (
    <>
      <div className="space-y-5">
        <div className="rounded-[28px] bg-white p-5 shadow-soft">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-1.5 text-[9px] font-semibold text-faint">
              <Clock3 size={12} /> {dirty ? "Unsaved changes" : savedAt}
            </div>
            <Button
              onClick={saveMemo}
              className={`flex items-center gap-1.5 rounded-full px-3 py-2 text-[9px] font-bold transition ${dirty ? "bg-ink text-white" : "bg-surface text-muted"}`}
            >
              <Save size={13} /> {dirty ? "Save" : "Saved"}
            </Button>
          </div>

          <Input
            value={title}
            onChange={(event) => { setTitle(event.target.value); setDirty(true); }}
            placeholder="Memo title"
            className="mt-5 text-[24px] font-extrabold tracking-[-0.04em] text-ink placeholder:text-line"
          />
          <div className="mt-3 flex items-center gap-2">
            {dueDate ? (
              <>
                <DeadlineBadge date={dueDate} />
                <label className="rounded-full bg-surface px-2.5 py-1.5 text-[8px] font-bold text-muted">
                  Edit
                  <Input
                    type="date"
                    value={dueDate}
                    onChange={(event) => { setDueDate(event.target.value); setDirty(true); }}
                    className="absolute h-px w-px opacity-0"
                  />
                </label>
                <Button onClick={() => { setDueDate(""); setDirty(true); }} className="text-[8px] font-bold text-faint">Remove</Button>
              </>
            ) : (
              <label className="flex items-center gap-1.5 rounded-full bg-surface px-3 py-2 text-[9px] font-bold text-muted">
                <CalendarDays size={12} /> Add due date
                <Input
                  type="date"
                  value={dueDate}
                  onChange={(event) => { setDueDate(event.target.value); setDirty(true); }}
                  className="absolute h-px w-px opacity-0"
                />
              </label>
            )}
          </div>

          <div className="mt-5 flex items-center gap-1 overflow-x-auto border-y border-line py-2 scrollbar-none">
            <Button onClick={() => formatText("bold")} aria-label="Bold" className="flex size-8 shrink-0 items-center justify-center rounded-lg text-muted hover:bg-surface"><Bold size={15} /></Button>
            <Button onClick={() => formatText("italic")} aria-label="Italic" className="flex size-8 shrink-0 items-center justify-center rounded-lg text-muted hover:bg-surface"><Italic size={15} /></Button>
            <Button onClick={() => formatText("insertUnorderedList")} aria-label="Bullet list" className="flex size-8 shrink-0 items-center justify-center rounded-lg text-muted hover:bg-surface"><List size={15} /></Button>
            <Button onClick={() => formatText("formatBlock", "blockquote")} aria-label="Quote" className="rounded-lg px-2.5 py-2 text-[10px] font-extrabold text-muted hover:bg-surface">“ ”</Button>
            <span className="mx-1 h-5 w-px bg-line" />
            <Button onClick={() => formatText("createLink", "https://memospace.app")} aria-label="Add link" className="flex size-8 shrink-0 items-center justify-center rounded-lg text-muted hover:bg-surface"><Link2 size={15} /></Button>
            <Button onClick={() => setAttachmentPicker(true)} className="ml-auto flex shrink-0 items-center gap-1.5 rounded-full bg-surface px-3 py-2 text-[9px] font-bold text-muted"><Paperclip size={13} /> Attach</Button>
          </div>

          <div
            ref={editorRef}
            contentEditable
            suppressContentEditableWarning
            onInput={() => setDirty(true)}
            className="memo-editor min-h-48 py-5 text-xs leading-6 text-muted outline-none"
            dangerouslySetInnerHTML={{ __html: initialContent.current }}
          />
        </div>

        <div>
          <SectionTitle title="Attachments" action="Add" onAction={() => setAttachmentPicker(true)} />
          <div className="space-y-2.5">
            {attachments.length === 0 && (
              <Button onClick={() => setAttachmentPicker(true)} className="flex w-full items-center justify-center gap-2 rounded-[20px] border border-dashed border-line py-5 text-[10px] font-bold text-muted">
                <Paperclip size={14} /> Add photo, video, PDF, or document
              </Button>
            )}
            {attachments.map((attachment) => {
              const Icon = attachment.icon;
              return (
                <div key={attachment.id} className="flex items-center gap-3 rounded-[20px] bg-white p-3 shadow-soft">
                  <Button
                    onClick={() => navigate({ kind: "asset", title: attachment.name, subtitle: `${attachment.type} · ${attachment.meta}` })}
                    className="flex min-w-0 flex-1 items-center gap-3 text-left"
                  >
                    <span className={`flex size-10 shrink-0 items-center justify-center rounded-xl ${attachment.color}`}><Icon size={17} /></span>
                    <span className="min-w-0 flex-1">
                      <span className="block truncate text-xs font-bold text-ink">{attachment.name}</span>
                      <span className="mt-1 block text-[9px] text-faint">{attachment.type} · {attachment.meta}</span>
                    </span>
                  </Button>
                  <Button
                    aria-label={`Remove ${attachment.name}`}
                    onClick={() => { setAttachments((current) => current.filter((item) => item.id !== attachment.id)); setDirty(true); }}
                    className="flex size-8 items-center justify-center rounded-full text-faint hover:bg-surface"
                  >
                    <X size={14} />
                  </Button>
                </div>
              );
            })}
          </div>
        </div>

        <div>
          <SectionTitle title="Checklist" />
          <div className="rounded-[24px] bg-white p-4 shadow-soft">
            <div className="space-y-1">
              {checklist.map((item) => (
                <div key={item.id} className="flex items-center gap-2 rounded-xl py-1.5">
                  <Button
                    onClick={() => {
                      setChecklist((current) => current.map((check) => check.id === item.id ? { ...check, done: !check.done } : check));
                      setDirty(true);
                    }}
                    aria-label={item.done ? "Mark incomplete" : "Mark complete"}
                    className={`flex size-5 shrink-0 items-center justify-center rounded-md border ${item.done ? "border-olive bg-olive text-white" : "border-line"}`}
                  >
                    {item.done && <Check size={12} />}
                  </Button>
                  {editingChecklist === item.id ? (
                    <Input
                      autoFocus
                      value={editingChecklistText}
                      onChange={(event) => setEditingChecklistText(event.target.value)}
                      onKeyDown={(event) => {
                        if (event.key === "Enter") saveChecklistEdit(item.id);
                        if (event.key === "Escape") setEditingChecklist(null);
                      }}
                      className="min-w-0 flex-1 rounded-lg bg-surface px-2 py-1.5 text-xs text-ink"
                    />
                  ) : (
                    <span className={`min-w-0 flex-1 text-xs ${item.done ? "text-faint line-through" : "text-muted"}`}>{item.text}</span>
                  )}
                  {editingChecklist === item.id ? (
                    <Button onClick={() => saveChecklistEdit(item.id)} className="text-[8px] font-bold text-olive">Save</Button>
                  ) : (
                    <Button onClick={() => { setEditingChecklist(item.id); setEditingChecklistText(item.text); }} aria-label={`Edit ${item.text}`} className="flex size-7 items-center justify-center rounded-full text-faint hover:bg-surface"><Pencil size={12} /></Button>
                  )}
                  <Button
                    onClick={() => { setChecklist((current) => current.filter((check) => check.id !== item.id)); setDirty(true); }}
                    aria-label={`Delete ${item.text}`}
                    className="flex size-7 items-center justify-center rounded-full text-faint hover:bg-peach hover:text-caramel"
                  >
                    <Trash2 size={12} />
                  </Button>
                </div>
              ))}
            </div>
            <div className="mt-3 flex items-center gap-2 border-t border-line pt-3">
              <Plus size={14} className="text-faint" />
              <Input
                value={newChecklist}
                onChange={(event) => setNewChecklist(event.target.value)}
                onKeyDown={(event) => { if (event.key === "Enter") addChecklistItem(); }}
                placeholder="Add checklist item"
                className="flex-1 text-[10px] text-ink placeholder:text-faint"
              />
              <Button disabled={!newChecklist.trim()} onClick={addChecklistItem} className="rounded-full bg-ink px-3 py-1.5 text-[9px] font-bold text-white disabled:opacity-30">Add</Button>
            </div>
          </div>
        </div>

        <div>
          <SectionTitle title={`Comments · ${comments.length}`} />
          <div className="space-y-3">
            {comments.map((comment) => (
              <div key={comment.id} className="rounded-[24px] bg-white p-4 shadow-soft">
                <div className="flex gap-3">
                  <Avatar initials={comment.initials} tone={comment.tone} className="size-8" />
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-bold text-ink">{comment.name}</span>
                      <span className="text-[9px] text-faint">{comment.time}</span>
                    </div>
                    <div className="mt-1.5 text-[10px] leading-5 text-muted">{comment.body}</div>
                    <Button onClick={() => { setReplyingTo(replyingTo === comment.id ? null : comment.id); setReplyText(""); }} className="mt-2 flex items-center gap-1 text-[9px] font-bold text-muted">
                      <Reply size={12} /> Reply
                    </Button>
                  </div>
                </div>
                {comment.replies.length > 0 && (
                  <div className="ml-5 mt-3 space-y-3 border-l border-line pl-4">
                    {comment.replies.map((reply) => (
                      <div key={reply.id} className="flex gap-2.5">
                        <Avatar initials={reply.initials} tone={reply.tone} className="size-7" />
                        <div className="min-w-0 flex-1">
                          <div className="text-[10px] font-bold text-ink">{reply.name} <span className="ml-1 font-normal text-faint">{reply.time}</span></div>
                          <div className="mt-1 text-[10px] leading-4 text-muted">{reply.body}</div>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
                {replyingTo === comment.id && (
                  <div className="ml-5 mt-3 flex items-center gap-2 rounded-2xl bg-surface px-3 py-2">
                    <Input
                      autoFocus
                      value={replyText}
                      onChange={(event) => setReplyText(event.target.value)}
                      onKeyDown={(event) => { if (event.key === "Enter") addReply(comment.id); }}
                      placeholder={`Reply to ${comment.name.split(" ")[0]}...`}
                      className="flex-1 text-[10px] text-ink placeholder:text-faint"
                    />
                    <Button disabled={!replyText.trim()} onClick={() => addReply(comment.id)} aria-label="Send reply" className="flex size-7 items-center justify-center rounded-full bg-ink text-white disabled:opacity-30"><Send size={12} /></Button>
                  </div>
                )}
              </div>
            ))}
            <div className="flex items-center gap-2 rounded-[22px] bg-white p-3 shadow-soft">
              <Avatar initials="NA" className="size-8" />
              <Input
                value={commentText}
                onChange={(event) => setCommentText(event.target.value)}
                onKeyDown={(event) => { if (event.key === "Enter") addComment(); }}
                placeholder="Add a comment..."
                className="flex-1 text-[10px] text-ink placeholder:text-faint"
              />
              <Button disabled={!commentText.trim()} onClick={addComment} aria-label="Post comment" className="flex size-8 items-center justify-center rounded-full bg-ink text-white disabled:opacity-30"><Send size={13} /></Button>
            </div>
          </div>
        </div>
      </div>

      {attachmentPicker && (
        <SheetFrame title="Add attachment" description="Add media or a document to this memo." onClose={() => setAttachmentPicker(false)}>
          <div className="mt-5 grid grid-cols-2 gap-2.5">
            {[
              { type: "Photo" as const, icon: Image, color: "bg-peach text-caramel" },
              { type: "Video" as const, icon: Video, color: "bg-lilac text-plum" },
              { type: "PDF" as const, icon: FileText, color: "bg-mint text-olive" },
              { type: "Document" as const, icon: File, color: "bg-surface text-muted" },
            ].map(({ type, icon: Icon, color }) => (
              <Button key={type} onClick={() => addAttachment(type)} className="rounded-[20px] bg-white p-3 text-center shadow-soft">
                <span className={`mx-auto flex size-10 items-center justify-center rounded-xl ${color}`}><Icon size={17} /></span>
                <span className="mt-2 block text-[9px] font-bold text-ink">{type}</span>
              </Button>
            ))}
          </div>
        </SheetFrame>
      )}
    </>
  );
}

function DetailScreen({
  screen,
  onBack,
  navigate,
  openSheet,
  workspaces,
}: {
  screen: Screen;
  onBack: () => void;
  navigate: Navigate;
  openSheet: OpenSheet;
  workspaces: Workspace[];
}) {
  const [query, setQuery] = useState("");
  const [completed, setCompleted] = useState<number[]>([0]);
  const isTask = screen.kind === "task";
  const memberWorkspace = workspaces.find((workspace) => workspace.id === screen.workspaceId);

  return (
    <div className="min-h-full pb-10">
      <DetailHeader screen={screen} onBack={onBack} openSheet={openSheet} />
      <div className="px-5">
        {screen.kind === "search" && (
          <>
            <div className="flex items-center gap-2 rounded-2xl bg-white px-4 py-3 shadow-soft">
              <Search size={17} className="text-faint" />
              <Input
                autoFocus
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                placeholder="Type to search..."
                className="text-xs text-ink placeholder:text-faint"
              />
              {query && (
                <Button aria-label="Clear search" onClick={() => setQuery("")} className="text-faint">
                  <X size={16} />
                </Button>
              )}
            </div>
            <div className="mt-6">
              <SectionTitle title={query ? `Results for “${query}”` : "Recent searches"} />
              <div className="space-y-2.5">
                {["Launch checklist", "Visual direction", "Product ideas"].map((item, index) => (
                  <Button
                    key={item}
                    onClick={() => navigate({ kind: "memo", title: item, subtitle: index === 1 ? "Northstar Studio" : "Personal" })}
                    className="flex w-full items-center gap-3 rounded-2xl bg-white p-3 text-left shadow-soft"
                  >
                    <div className={`flex size-10 items-center justify-center rounded-xl ${index === 1 ? "bg-lilac" : "bg-peach"}`}>
                      <FileText size={17} />
                    </div>
                    <div className="flex-1">
                      <div className="text-xs font-bold text-ink">{item}</div>
                      <div className="mt-1 text-[10px] text-faint">Memo · Updated recently</div>
                    </div>
                    <ChevronRight size={15} className="text-faint" />
                  </Button>
                ))}
              </div>
            </div>
          </>
        )}

        {(screen.kind === "memo" || screen.kind === "canvas-note") && (
          <MemoEditor screen={screen} navigate={navigate} />
        )}

        {isTask && (
          <>
            <div className="rounded-[26px] bg-white p-5 shadow-soft">
              <div className="flex items-center gap-2 text-[10px] font-semibold text-faint">
                <Clock3 size={13} />
                Last edited just now
              </div>
              <div className="mt-6 text-[21px] font-extrabold leading-tight tracking-[-0.035em] text-ink">{screen.title}</div>
              <div className="mt-4 text-xs leading-6 text-muted">
                {screen.kind === "task"
                  ? "Keep the scope focused, confirm the final details with the team, and share an update when this card is ready."
                  : "Capture the important context here. Keep ideas clear, actionable, and easy for everyone in the workspace to build on."}
              </div>
              <div className="mt-5 space-y-3">
                {["Outline the key idea", "Add supporting details", "Share with the team"].map((item, index) => (
                  <Button
                    key={item}
                    onClick={() => setCompleted((current) => current.includes(index) ? current.filter((itemIndex) => itemIndex !== index) : [...current, index])}
                    className="flex w-full items-center gap-3 text-left text-xs text-muted"
                  >
                    <span className={`flex size-5 items-center justify-center rounded-md border ${completed.includes(index) ? "border-olive bg-olive text-white" : "border-line"}`}>
                      {completed.includes(index) && <Check size={12} />}
                    </span>
                    <span>{item}</span>
                  </Button>
                ))}
              </div>
              <div className="mt-6 flex gap-2 border-t border-line pt-4">
                <Button onClick={() => openSheet("asset-actions")} className="flex items-center gap-1.5 rounded-full bg-surface px-3 py-2 text-[10px] font-bold text-muted">
                  <Paperclip size={14} /> Attach
                </Button>
                <Button onClick={() => openSheet("memo-actions")} className="flex items-center gap-1.5 rounded-full bg-surface px-3 py-2 text-[10px] font-bold text-muted">
                  <MessageCircle size={14} /> Comment
                </Button>
              </div>
            </div>
            <div className="mt-5">
              <SectionTitle title="Comments" />
              <div className="rounded-[22px] bg-white p-4 shadow-soft">
                <Activity avatar="AR" tone="sand" name="Ardi" text="commented on" subject="this memo" time="12m" onClick={() => openSheet("memo-actions")} />
                <div className="mt-4 flex items-center gap-2 rounded-2xl bg-surface px-3 py-2">
                  <span className="flex-1 text-[10px] text-faint">Write a reply...</span>
                  <Button onClick={() => openSheet("memo-actions")} aria-label="Send reply" className="flex size-7 items-center justify-center rounded-full bg-ink text-white">
                    <Send size={13} />
                  </Button>
                </div>
              </div>
            </div>
          </>
        )}

        {(screen.kind === "collection" || screen.kind === "stats" || screen.kind === "activity") && (
          <div className="space-y-3">
            {["Product ideas", "Research notes", "Launch checklist", "Visual direction"].map((item, index) => (
              <Button
                key={item}
                onClick={() => navigate({ kind: index === 2 ? "task" : "memo", title: item, subtitle: screen.title })}
                className="flex w-full items-center gap-3 rounded-[22px] bg-white p-4 text-left shadow-soft"
              >
                <div className={`flex size-10 items-center justify-center rounded-2xl ${index % 2 ? "bg-mint" : "bg-peach"}`}>
                  {screen.kind === "activity" ? <Clock3 size={17} /> : <FileText size={17} />}
                </div>
                <div className="flex-1">
                  <div className="text-xs font-bold text-ink">{item}</div>
                  <div className="mt-1 text-[10px] text-faint">{screen.kind === "activity" ? "Updated by a teammate" : "Updated recently"}</div>
                </div>
                <ChevronRight size={15} className="text-faint" />
              </Button>
            ))}
          </div>
        )}

        {screen.kind === "asset" && (
          <>
            <div className="flex h-72 items-center justify-center rounded-[28px] bg-ink text-white shadow-card">
              {screen.subtitle?.includes("Video") ? <Video size={48} strokeWidth={1.4} /> : screen.subtitle?.includes("photo") ? <Image size={48} strokeWidth={1.4} /> : <File size={48} strokeWidth={1.4} />}
            </div>
            <div className="mt-4 rounded-[22px] bg-white p-4 shadow-soft">
              <div className="text-xs font-bold text-ink">File details</div>
              <div className="mt-3 grid grid-cols-2 gap-4 text-[10px] text-muted">
                <div><span className="block text-faint">Added</span><span className="mt-1 block font-semibold">May 24, 2025</span></div>
                <div><span className="block text-faint">Workspace</span><span className="mt-1 block font-semibold">Northstar Studio</span></div>
              </div>
            </div>
          </>
        )}

        {screen.kind === "members" && (
          <div className="space-y-2.5">
            {(memberWorkspace?.members || initialWorkspaces[0].members).map((member) => (
              <Button key={member.id} onClick={() => navigate({ kind: "profile", title: member.name, subtitle: member.role })} className="flex w-full items-center gap-3 rounded-[20px] bg-white p-3 text-left shadow-soft">
                <Avatar initials={member.initials} tone={member.tone} className="size-10" />
                <div className="min-w-0 flex-1">
                  <div className="truncate text-xs font-bold text-ink">{member.name}</div>
                  <div className="mt-1 text-[10px] text-faint">{member.status}</div>
                </div>
                <span className={`rounded-full px-2 py-1 text-[8px] font-bold ${member.role === "Owner" ? "bg-peach text-caramel" : "bg-surface text-muted"}`}>{member.role}</span>
                <ChevronRight size={15} className="text-faint" />
              </Button>
            ))}
          </div>
        )}

        {(screen.kind === "profile" || screen.kind === "settings") && (
          <div className="overflow-hidden rounded-[24px] bg-white px-4 shadow-soft">
            <ProfileRow icon={UserRound} label="Personal information" onClick={() => openSheet("edit-profile")} />
            <ProfileRow icon={Bell} label="Notification preferences" value="On" onClick={() => openSheet("notification-settings")} />
            <ProfileRow icon={Globe2} label="Language" value="English" onClick={() => openSheet("language")} />
            <ProfileRow icon={Trash2} label="Delete account" last onClick={() => openSheet("memo-actions")} />
          </div>
        )}

        {screen.kind === "help" && (
          <div className="space-y-3">
            {["Getting started", "Working with your team", "Memos and attachments", "Contact support"].map((item, index) => (
              <Button
                key={item}
                onClick={() => index === 3 ? openSheet("support") : navigate({ kind: "help", title: item, subtitle: "Help article" })}
                className="flex w-full items-center gap-3 rounded-[20px] bg-white p-4 text-left shadow-soft"
              >
                <MessageCircle size={17} className="text-muted" />
                <span className="flex-1 text-xs font-bold text-ink">{item}</span>
                <ChevronRight size={15} className="text-faint" />
              </Button>
            ))}
          </div>
        )}

        {screen.kind === "upgrade" && (
          <div className="overflow-hidden rounded-[28px] bg-ink p-6 text-white shadow-card">
            <Sparkles size={26} />
            <div className="mt-6 text-[24px] font-extrabold tracking-[-0.04em]">Unlimited space for your best work.</div>
            <div className="mt-3 text-xs leading-6 text-white/55">Create unlimited workspaces, upload larger files, and keep your full version history.</div>
            <Button onClick={() => openSheet("upgrade")} className="mt-6 w-full rounded-full bg-white py-3 text-xs font-bold text-ink">Choose your plan</Button>
          </div>
        )}
      </div>
    </div>
  );
}

type GenericSheetKind = Exclude<SheetKind, "notifications" | "workspace-choice" | "create-workspace" | "join-workspace" | "invite">;

function SheetFrame({ title, description, onClose, children }: { title: string; description: string; onClose: () => void; children: ReactNode }) {
  return (
    <div className="absolute inset-0 z-40 flex items-end bg-ink/30 backdrop-blur-[2px]" onClick={onClose}>
      <div className="w-full rounded-t-[32px] bg-canvas px-5 pb-8 pt-4" onClick={(event) => event.stopPropagation()}>
        <div className="mx-auto mb-4 h-1 w-10 rounded-full bg-line" />
        <div className="flex items-start justify-between gap-3">
          <div>
            <div className="text-lg font-extrabold text-ink">{title}</div>
            <div className="mt-1 text-[10px] leading-4 text-muted">{description}</div>
          </div>
          <Button onClick={onClose} aria-label="Close sheet" className="flex size-9 shrink-0 items-center justify-center rounded-full bg-white text-ink">
            <X size={17} />
          </Button>
        </div>
        {children}
      </div>
    </div>
  );
}

function WorkspaceChoiceSheet({ onClose, onChoose }: { onClose: () => void; onChoose: (choice: "create-workspace" | "join-workspace") => void }) {
  return (
    <SheetFrame title="Workspace" description="Create a new team space or join one with an invitation code." onClose={onClose}>
      <div className="mt-5 grid grid-cols-2 gap-3">
        <Button onClick={() => onChoose("create-workspace")} className="rounded-[22px] bg-ink p-4 text-left text-white shadow-card">
          <span className="flex size-10 items-center justify-center rounded-xl bg-white/10"><Plus size={17} /></span>
          <span className="mt-4 block text-xs font-bold">Create workspace</span>
          <span className="mt-1 block text-[9px] leading-4 text-white/50">Start a new space and invite your team.</span>
        </Button>
        <Button onClick={() => onChoose("join-workspace")} className="rounded-[22px] bg-white p-4 text-left shadow-soft">
          <span className="flex size-10 items-center justify-center rounded-xl bg-mint text-olive"><LogIn size={17} /></span>
          <span className="mt-4 block text-xs font-bold text-ink">Join workspace</span>
          <span className="mt-1 block text-[9px] leading-4 text-faint">Enter a unique workspace invitation code.</span>
        </Button>
      </div>
    </SheetFrame>
  );
}

function CreateWorkspaceSheet({ onClose, onCreate }: { onClose: () => void; onCreate: (name: string, description: string) => void }) {
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  return (
    <SheetFrame title="Create workspace" description="Start a focused space for your team or project." onClose={onClose}>
      <div className="mt-5 space-y-3">
        <label className="block rounded-[20px] bg-white px-4 py-3 shadow-soft">
          <span className="text-[9px] font-bold uppercase tracking-wider text-faint">Workspace name</span>
          <Input value={name} maxLength={32} onChange={(event) => setName(event.target.value)} placeholder="e.g. Product Launch" className="mt-1.5 text-xs font-semibold text-ink placeholder:text-faint" />
        </label>
        <label className="block rounded-[20px] bg-white px-4 py-3 shadow-soft">
          <span className="text-[9px] font-bold uppercase tracking-wider text-faint">Description</span>
          <Input value={description} maxLength={72} onChange={(event) => setDescription(event.target.value)} placeholder="What will your team work on?" className="mt-1.5 text-xs text-ink placeholder:text-faint" />
        </label>
        <div className="flex items-center gap-3 rounded-[20px] bg-mint p-4">
          <div className="flex size-9 items-center justify-center rounded-xl bg-white text-olive"><Users size={17} /></div>
          <div><div className="text-xs font-bold text-ink">You’ll be the owner</div><div className="mt-1 text-[9px] text-muted">An invite code will be generated automatically.</div></div>
        </div>
      </div>
      <Button
        disabled={!name.trim()}
        onClick={() => onCreate(name.trim(), description.trim() || "A new collaborative workspace.")}
        className="mt-4 w-full rounded-full bg-ink py-3.5 text-xs font-bold text-white disabled:cursor-not-allowed disabled:opacity-30"
      >
        Create workspace
      </Button>
    </SheetFrame>
  );
}

function JoinWorkspaceSheet({ onClose, onJoin }: { onClose: () => void; onJoin: (code: string) => "joined" | "invalid" | "exists" }) {
  const [code, setCode] = useState("");
  const [message, setMessage] = useState("");
  const submit = () => {
    const result = onJoin(code.trim().toUpperCase());
    if (result === "invalid") setMessage("That code wasn’t found. Try DESIGN-42 or SPRINT-88.");
    if (result === "exists") setMessage("You’re already a member of this workspace.");
  };
  return (
    <SheetFrame title="Join workspace" description="Enter the unique code shared by a workspace owner." onClose={onClose}>
      <div className="mt-5 rounded-[22px] bg-white px-4 py-4 shadow-soft">
        <div className="text-[9px] font-bold uppercase tracking-wider text-faint">Invitation code</div>
        <Input
          autoFocus
          value={code}
          maxLength={12}
          onChange={(event) => { setCode(event.target.value.toUpperCase()); setMessage(""); }}
          onKeyDown={(event) => { if (event.key === "Enter" && code.trim()) submit(); }}
          placeholder="DESIGN-42"
          className="mt-2 text-lg font-extrabold uppercase tracking-[0.12em] text-ink placeholder:text-line"
        />
      </div>
      {message && <div className="mt-3 rounded-2xl bg-peach px-4 py-3 text-[10px] font-semibold text-caramel">{message}</div>}
      <div className="mt-3 text-center text-[9px] text-faint">Demo codes: DESIGN-42 · SPRINT-88</div>
      <Button
        disabled={!code.trim()}
        onClick={submit}
        className="mt-4 w-full rounded-full bg-ink py-3.5 text-xs font-bold text-white disabled:cursor-not-allowed disabled:opacity-30"
      >
        Join workspace
      </Button>
    </SheetFrame>
  );
}

function InviteWorkspaceSheet({
  workspace,
  onClose,
  onRegenerate,
}: {
  workspace: Workspace;
  onClose: () => void;
  onRegenerate: () => void;
}) {
  const [copied, setCopied] = useState(false);
  const copyCode = async () => {
    try {
      await navigator.clipboard.writeText(workspace.code);
    } catch {
      // Clipboard permissions can be unavailable in embedded previews.
    }
    setCopied(true);
  };
  return (
    <SheetFrame title="Invite teammates" description={`Share this unique code to join ${workspace.name}.`} onClose={onClose}>
      <div className="mt-5 rounded-[24px] bg-ink p-5 text-center text-white shadow-card">
        <div className="text-[9px] font-bold uppercase tracking-[0.18em] text-white/45">Workspace code</div>
        <div className="mt-3 text-[24px] font-extrabold tracking-[0.12em]">{workspace.code}</div>
        <div className="mt-2 text-[9px] text-white/45">Codes are unique to each workspace.</div>
      </div>
      <div className="mt-3 grid grid-cols-2 gap-2.5">
        <Button onClick={copyCode} className="flex items-center justify-center gap-2 rounded-full bg-white py-3 text-[10px] font-bold text-ink shadow-soft">
          {copied ? <Check size={14} /> : <Copy size={14} />} {copied ? "Copied" : "Copy code"}
        </Button>
        <Button
          disabled={workspace.currentUserRole !== "Owner"}
          onClick={() => { onRegenerate(); setCopied(false); }}
          className="flex items-center justify-center gap-2 rounded-full bg-white py-3 text-[10px] font-bold text-ink shadow-soft disabled:cursor-not-allowed disabled:opacity-40"
        >
          <RefreshCw size={14} /> New code
        </Button>
      </div>
      <div className="mt-4 flex items-center gap-3 rounded-[20px] bg-white p-4 shadow-soft">
        <Avatar initials="NA" className="size-9" />
        <div className="flex-1"><div className="text-xs font-bold text-ink">Invite as member</div><div className="mt-1 text-[9px] text-faint">New people can view, create, and edit memos.</div></div>
      </div>
      <Button onClick={onClose} className="mt-4 w-full rounded-full bg-ink py-3.5 text-xs font-bold text-white">Done</Button>
    </SheetFrame>
  );
}

const sheetContent: Record<GenericSheetKind, { title: string; description: string; options: string[]; primary?: string }> = {
  "home-menu": { title: "Your space", description: "Manage your personal MemoSpace.", options: ["View space details", "Share weekly summary"], primary: "Done" },
  "library-filter": { title: "Filter library", description: "Choose what appears in your library.", options: ["Created by me", "Shared with me", "Has attachments"], primary: "Apply filters" },
  "edit-collections": { title: "Edit collections", description: "Reorder, rename, or create a collection.", options: ["Create collection", "Reorder collections", "Manage archive"], primary: "Done" },
  sort: { title: "Sort items", description: "Choose how library items are ordered.", options: ["Recently updated", "Date created", "Name A–Z"], primary: "Apply" },
  "new-card": { title: "Add a board card", description: "Create a task in the selected column.", options: ["Add task details", "Assign a teammate", "Set due date"], primary: "Create card" },
  "canvas-tools": { title: "Canvas tools", description: "Add an item or adjust the canvas view.", options: ["Add sticky note", "Add checklist", "Fit to screen"], primary: "Done" },
  "edit-profile": { title: "Edit profile", description: "Update how your name and profile appear.", options: ["Change photo", "Edit display name", "Update bio"], primary: "Save changes" },
  "notification-settings": { title: "Notifications", description: "Choose which updates you receive.", options: ["Mentions and replies", "Workspace invitations", "Task updates"], primary: "Save preferences" },
  language: { title: "Language", description: "Select your preferred app language.", options: ["English", "Bahasa Indonesia", "Español"], primary: "Apply language" },
  "memo-actions": { title: "More actions", description: "Manage this item or share it with others.", options: ["Share", "Move to collection", "Duplicate"], primary: "Done" },
  upgrade: { title: "Choose a plan", description: "MemoSpace Plus is billed monthly and can be cancelled anytime.", options: ["Individual · $6/month", "Team · $12/member"], primary: "Continue" },
  support: { title: "Contact support", description: "Our support team usually replies within one business day.", options: ["Send us a message", "Report a problem"], primary: "Continue" },
  "asset-actions": { title: "File actions", description: "Manage this attachment.", options: ["Download", "Share", "Move to collection"], primary: "Done" },
};

function ActionSheet({ sheet, onClose }: { sheet: GenericSheetKind; onClose: () => void }) {
  const content = sheetContent[sheet];
  const [selected, setSelected] = useState(content.options[0]);
  const [applied, setApplied] = useState(false);
  return (
    <div className="absolute inset-0 z-40 flex items-end bg-ink/30 backdrop-blur-[2px]" onClick={onClose}>
      <div className="w-full rounded-t-[32px] bg-canvas px-5 pb-8 pt-4" onClick={(event) => event.stopPropagation()}>
        <div className="mx-auto mb-4 h-1 w-10 rounded-full bg-line" />
        <div className="flex items-center justify-between">
          <div>
            <div className="text-lg font-extrabold text-ink">{content.title}</div>
            <div className="mt-1 text-[10px] leading-4 text-muted">{content.description}</div>
          </div>
          <Button onClick={onClose} aria-label="Close sheet" className="flex size-9 shrink-0 items-center justify-center rounded-full bg-white text-ink">
            <X size={17} />
          </Button>
        </div>
        <div className="mt-5 overflow-hidden rounded-[22px] bg-white px-4 shadow-soft">
          {content.options.map((option, index) => (
            <Button
              key={option}
              onClick={() => { setSelected(option); setApplied(false); }}
              className={`flex w-full items-center gap-3 py-4 text-left ${index < content.options.length - 1 ? "border-b border-line" : ""}`}
            >
              <span className={`flex size-5 items-center justify-center rounded-full border ${selected === option ? "border-ink bg-ink text-white" : "border-line"}`}>
                {selected === option && <Check size={12} />}
              </span>
              <span className="flex-1 text-xs font-semibold text-ink">{option}</span>
            </Button>
          ))}
        </div>
        {applied && (
          <div className="mt-3 flex items-center justify-center gap-2 rounded-2xl bg-mint px-4 py-3 text-[10px] font-bold text-olive">
            <Check size={13} /> {selected} applied
          </div>
        )}
        <Button onClick={() => applied ? onClose() : setApplied(true)} className="mt-4 w-full rounded-full bg-ink py-3.5 text-xs font-bold text-white">
          {applied ? "Done" : content.primary || "Apply"}
        </Button>
      </div>
    </div>
  );
}

function Notifications({ onClose, navigate }: { onClose: () => void; navigate: Navigate }) {
  return (
    <div className="absolute inset-0 z-40 flex items-end bg-ink/30 backdrop-blur-[2px]" onClick={onClose}>
      <div className="w-full rounded-t-[32px] bg-canvas px-5 pb-8 pt-4" onClick={(event) => event.stopPropagation()}>
        <div className="mx-auto mb-4 h-1 w-10 rounded-full bg-line" />
        <div className="flex items-center justify-between">
          <div className="text-lg font-extrabold text-ink">Notifications</div>
          <Button onClick={onClose} className="flex size-9 items-center justify-center rounded-full bg-white text-ink">
            <X size={17} />
          </Button>
        </div>
        <div className="mt-5 space-y-3">
          <Notification icon={Users} title="Workspace invitation" text="Raka invited you to join Brand Sprint." time="2m" unread onClick={() => { onClose(); navigate({ kind: "members", title: "Brand Sprint", subtitle: "Workspace invitation" }); }} />
          <Notification icon={MessageCircle} title="New reply" text="Jade replied to your comment in Launch plan." time="1h" unread onClick={() => { onClose(); navigate({ kind: "memo", title: "Launch plan", subtitle: "Reply from Jade" }); }} />
          <Notification icon={CheckCircle2} title="Task completed" text="Ardi completed Update style guide." time="3h" onClick={() => { onClose(); navigate({ kind: "task", title: "Update style guide", subtitle: "Completed by Ardi" }); }} />
        </div>
      </div>
    </div>
  );
}

function Notification({ icon: Icon, title, text, time, unread, onClick }: { icon: LucideIcon; title: string; text: string; time: string; unread?: boolean; onClick: () => void }) {
  return (
    <Button onClick={onClick} className="relative flex w-full gap-3 rounded-[20px] bg-white p-3.5 text-left shadow-soft">
      <div className="flex size-10 shrink-0 items-center justify-center rounded-2xl bg-soft text-muted"><Icon size={17} /></div>
      <div className="flex-1">
        <div className="text-xs font-bold text-ink">{title}</div>
        <div className="mt-1 text-[10px] leading-4 text-muted">{text}</div>
      </div>
      <div className="text-[9px] text-faint">{time}</div>
      {unread && <span className="absolute right-3 top-8 size-1.5 rounded-full bg-caramel" />}
    </Button>
  );
}

function BottomNav({ active, onChange }: { active: Tab; onChange: (tab: Tab) => void }) {
  const items: { id: Tab; label: string; icon: LucideIcon }[] = [
    { id: "home", label: "Home", icon: Home },
    { id: "library", label: "Library", icon: BookOpen },
    { id: "workspace", label: "Workspace", icon: Users },
    { id: "profile", label: "Profile", icon: UserRound },
  ];
  return (
    <div className="absolute bottom-4 left-4 right-4 z-30 flex items-center rounded-[24px] bg-ink p-1.5 shadow-nav">
      {items.map(({ id, label, icon: Icon }) => {
        const selected = active === id;
        return (
          <Button
            key={id}
            onClick={() => onChange(id)}
            className={`flex h-12 flex-1 items-center justify-center gap-1.5 rounded-[18px] transition ${
              selected ? "bg-white text-ink" : "text-white/45 hover:text-white"
            }`}
          >
            <Icon size={17} strokeWidth={selected ? 2.5 : 2} />
            {selected && <span className="text-[10px] font-bold">{label}</span>}
          </Button>
        );
      })}
    </div>
  );
}

export default function App() {
  const [tab, setTab] = useState<Tab>("home");
  const [screens, setScreens] = useState<Screen[]>([]);
  const [sheet, setSheet] = useState<SheetKind | null>(null);
  const [workspaces, setWorkspaces] = useState<Workspace[]>(initialWorkspaces);
  const [selectedWorkspaceId, setSelectedWorkspaceId] = useState(initialWorkspaces[0].id);
  const navigate: Navigate = (screen) => setScreens((current) => [...current, screen]);
  const goBack = () => setScreens((current) => current.slice(0, -1));
  const openSheet: OpenSheet = (nextSheet) => setSheet(nextSheet);
  const openInvite = (workspaceId: string) => {
    setSelectedWorkspaceId(workspaceId);
    setSheet("invite");
  };
  const createWorkspace = (name: string, description: string) => {
    const base = name.replace(/[^a-z0-9]/gi, "").slice(0, 5).toUpperCase() || "MEMO";
    let code = "";
    do {
      code = `${base}-${Math.random().toString(36).slice(2, 6).toUpperCase()}`;
    } while (workspaces.some((workspace) => workspace.code === code));
    const workspace: Workspace = {
      id: `${base.toLowerCase()}-${Date.now()}`,
      name,
      description,
      code,
      currentUserRole: "Owner",
      memos: 0,
      activeTasks: 0,
      completedTasks: 0,
      updated: "Just created",
      members: [
        { id: "naya", name: "Naya Anindita", initials: "NA", role: "Owner", tone: "dark", status: "You" },
      ],
    };
    setWorkspaces((current) => [...current, workspace]);
    setSelectedWorkspaceId(workspace.id);
    setSheet(null);
    navigate({ kind: "workspace-detail", title: workspace.name, subtitle: workspace.description, workspaceId: workspace.id });
  };
  const joinWorkspace = (code: string): "joined" | "invalid" | "exists" => {
    if (workspaces.some((workspace) => workspace.code === code)) return "exists";
    const available = joinableWorkspaces[code];
    if (!available) return "invalid";
    const workspace = { ...available, members: available.members.map((member) => ({ ...member })) };
    setWorkspaces((current) => [...current, workspace]);
    setSelectedWorkspaceId(workspace.id);
    setSheet(null);
    navigate({ kind: "workspace-detail", title: workspace.name, subtitle: workspace.description, workspaceId: workspace.id });
    return "joined";
  };
  const regenerateInviteCode = () => {
    setWorkspaces((current) =>
      current.map((workspace) => {
        if (workspace.id !== selectedWorkspaceId) return workspace;
        const prefix = workspace.name.replace(/[^a-z0-9]/gi, "").slice(0, 5).toUpperCase() || "MEMO";
        let code = "";
        do {
          code = `${prefix}-${Math.random().toString(36).slice(2, 6).toUpperCase()}`;
        } while (current.some((item) => item.code === code));
        return { ...workspace, code };
      }),
    );
  };
  const switchTab = (nextTab: Tab) => {
    setTab(nextTab);
    setScreens([]);
    setSheet(null);
  };
  const onNotify = () => openSheet("notifications");
  const pages = {
    home: <HomePage onNotify={onNotify} navigate={navigate} openSheet={openSheet} switchTab={switchTab} />,
    library: <LibraryPage onNotify={onNotify} navigate={navigate} openSheet={openSheet} />,
    workspace: <WorkspacePage onNotify={onNotify} navigate={navigate} openSheet={openSheet} workspaces={workspaces} />,
    profile: <ProfilePage onNotify={onNotify} navigate={navigate} openSheet={openSheet} />,
  };
  const activeScreen = screens.at(-1);
  const activeWorkspace = activeScreen?.workspaceId
    ? workspaces.find((workspace) => workspace.id === activeScreen.workspaceId)
    : undefined;
  const selectedWorkspace = workspaces.find((workspace) => workspace.id === selectedWorkspaceId) || workspaces[0];

  return (
    <main className="min-h-screen bg-page font-sans text-ink">
      <div className="app-shell relative mx-auto min-h-screen overflow-hidden bg-canvas shadow-phone">
        <div className="status-bar flex items-center justify-between px-6 pt-3 text-[10px] font-bold text-ink">
          <span>9:41</span>
          <div className="flex items-center gap-1.5">
            <span className="h-2 w-3 rounded-sm border border-ink" />
            <span className="h-2 w-3 rounded-sm bg-ink" />
            <span className="h-2 w-5 rounded-sm border border-ink p-px"><span className="block h-full w-3/4 rounded-[1px] bg-ink" /></span>
          </div>
        </div>
        <div className="app-scroll h-[calc(100vh-24px)] overflow-y-auto">
          {activeScreen?.kind === "workspace-detail" && activeWorkspace ? (
            <WorkspaceDetailScreen
              workspace={activeWorkspace}
              onBack={goBack}
              navigate={navigate}
              openSheet={openSheet}
              onInvite={() => openInvite(activeWorkspace.id)}
            />
          ) : activeScreen ? (
            <DetailScreen screen={activeScreen} onBack={goBack} navigate={navigate} openSheet={openSheet} workspaces={workspaces} />
          ) : (
            pages[tab]
          )}
        </div>
        {!activeScreen && <BottomNav active={tab} onChange={switchTab} />}
        {sheet === "notifications" && <Notifications onClose={() => setSheet(null)} navigate={navigate} />}
        {sheet === "workspace-choice" && <WorkspaceChoiceSheet onClose={() => setSheet(null)} onChoose={(choice) => setSheet(choice)} />}
        {sheet === "create-workspace" && <CreateWorkspaceSheet onClose={() => setSheet(null)} onCreate={createWorkspace} />}
        {sheet === "join-workspace" && <JoinWorkspaceSheet onClose={() => setSheet(null)} onJoin={joinWorkspace} />}
        {sheet === "invite" && <InviteWorkspaceSheet workspace={selectedWorkspace} onClose={() => setSheet(null)} onRegenerate={regenerateInviteCode} />}
        {sheet && !["notifications", "workspace-choice", "create-workspace", "join-workspace", "invite"].includes(sheet) && (
          <ActionSheet sheet={sheet as GenericSheetKind} onClose={() => setSheet(null)} />
        )}
      </div>
    </main>
  );
}
*/
